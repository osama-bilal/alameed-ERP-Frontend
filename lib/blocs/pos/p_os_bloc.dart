import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'dart:async';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/services/general_services.dart';

part 'p_os_event.dart';
part 'p_os_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final GeneralService<SaleInvoice> invoiceService =
      AppService.saleInvoiceService;
  final GeneralService<SaleItem> itemService = AppService.saleItemService;
  final GeneralService<POSView> productService = AppService.posViewService;
  final GeneralService<ProductCategory> productCategoryService =
      AppService.categoryService;

  // Simple in-memory retry queue
  final List<PendingOperation<dynamic>> _globalPending = [];

  PosBloc() : super(PosState()) {
    on<LoadPosData>(_onLoad);
    on<SetActiveInvoice>(_onSetActiveInvoice);
    on<CreateNewInvoice>(_onCreateNewInvoice);
    on<AddProductToActiveInvoice>(_onAddProduct);
    on<UpdateItem>(_onUpdateItem);
    on<RemoveItemFromActiveInvoice>(_onRemoveItem);

    // try to process pending ops periodically
    Timer.periodic(Duration(seconds: 20), (_) => _processPending());
  }

  // -------- Handlers --------
  Future<void> _onLoad(LoadPosData event, Emitter<PosState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    final fetchdrafts = GeneralService<SaleInvoice>(
      endpoint: "/invoices/sales/get_drafts/",
      fromMap: SaleInvoice.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final invoices = await fetchdrafts.fetchList();
      final products = await productService.fetchList();
      final categories = await productCategoryService.fetchList();
      // do not fetch items for all invoices here. fetch on demand.
      emit(
        state.copyWith(
          invoices: invoices,
          products: products,
          categories: categories,
          loading: false,
        ),
      );
      if (invoices.isNotEmpty) add(SetActiveInvoice(invoices.first));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onSetActiveInvoice(
    SetActiveInvoice event,
    Emitter<PosState> emit,
  ) async {
    final invoice = event.invoice;
    emit(state.copyWith(loading: true, activeInvoice: invoice, error: null));
    try {
      emit(state.copyWith(loading: false, activeInvoice: invoice));
    } catch (e) {
      // If fetch fails keep existing items if any
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          activeInvoice: invoice,
        ),
      );
    }
  }

  Future<void> _onCreateNewInvoice(
    CreateNewInvoice event,
    Emitter<PosState> emit,
  ) async {
    final tempId = -(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final localInvoice = SaleInvoice(
      id: tempId,
      userId: 1,
      status: 'draft',
      refundStatus: 'not_refunded',
      subtotal: '0.00',
      tax: '0.00',
      discount: '0.00',
      total: '0.00',
      paid: '0.00',
      date: DateTime.now(),
      items: [],
    );

    final newInvoices = [localInvoice, ...state.invoices];
    emit(state.copyWith(invoices: newInvoices, activeInvoice: localInvoice));

    try {
      final created = await invoiceService.create(localInvoice);
      final invoices = List<SaleInvoice>.from(state.invoices);
      final idx = invoices.indexWhere((i) => i.id == tempId);
      if (idx != -1) {
        final migratedItems = invoices[idx].items.map((it) {
          it.invoiceId = created.id!;
          return it;
        }).toList();
        created.items = migratedItems;
        invoices[idx] = created;
      }

      final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
        state.pendingItemOps,
      );
      if (pendingMap.containsKey(tempId)) {
        final ops = pendingMap.remove(tempId)!;
        final migratedOps = ops
            .map(
              (op) => PendingOperation<SaleItem>(
                type: op.type,
                item: op.item,
                localInvoiceId: created.id!,
              ),
            )
            .toList();
        pendingMap[created.id!] = migratedOps;
      }

      emit(
        state.copyWith(
          invoices: invoices,
          pendingItemOps: pendingMap,
          activeInvoice: created,
        ),
      );
    } catch (e) {
      _globalPending.add(
        PendingOperation<SaleInvoice>(
          type: PendingOpType.create,
          item: localInvoice,
          localInvoiceId: localInvoice.id!,
        ),
      );
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProductToActiveInvoice event,
    Emitter<PosState> emit,
  ) async {
    var invoice = state.activeInvoice;
    if (invoice == null) {
      // create a local invoice first
      add(CreateNewInvoice());
      // wait a tick then try again
      await Future.delayed(Duration(milliseconds: 50));
      invoice = state.activeInvoice;
      if (invoice == null) return;
      // abort if still null
    }

    final product = event.product;

    // final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
    final list = state.activeInvoice!.items;
    final idx = list.indexWhere((it) => it.variantId == product.id);
    if (idx != -1) {
      final item = list[idx];
      item.quantity++;
      // list[idx] = item;
      // state.activeInvoice!.items = list;
      emit(state.copyWith(loading: true));
      await Future.delayed(Duration(milliseconds: 50));
      emit(state.copyWith(loading: false));
      add(UpdateItem(item.id!, item));

      return;
    }
    final tempItemId = -(DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final item = SaleItem(
      id: tempItemId,
      variantId: product.id,
      quantity: 1,
      unitPrice: product.price.toString(),
      invoiceId: invoice.id!,
    );
    final invIndex = state.invoices.indexWhere(
      (inv) => inv.id == item.invoiceId,
    );

    if (invIndex != -1) {
      final invoices = List<SaleInvoice>.from(state.invoices);
      final items = List<SaleItem>.from(invoices[invIndex].items);
      final updated = [...items, item];
      invoices[invIndex].items = updated;
      emit(state.copyWith(invoices: invoices, error: null));
    }

    // try to create on server immediately
    try {
      final created = await itemService.create(item);
      // replace temp item with created item
      final invIndex = state.invoices.indexWhere(
        (inv) => inv.id == item.invoiceId,
      );

      if (invIndex != -1) {
        final invoices = List<SaleInvoice>.from(state.invoices);
        final items = List<SaleItem>.from(invoices[invIndex].items);
        final updated = items
            .map((it) => it.id == item.id ? created : it)
            .toList();
        invoices[invIndex].items = updated;
        emit(state.copyWith(invoices: invoices, error: null));
      }
      // itemsMap[invoice.id!] = updated;
      emit(state.copyWith(loading: true));
      await Future.delayed(Duration(milliseconds: 50));
      emit(state.copyWith(loading: false));
    } catch (e) {
      // push pending op for retry later
      final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
        state.pendingItemOps,
      );
      final op = PendingOperation<SaleItem>(
        type: PendingOpType.create,
        item: item,
        localInvoiceId: invoice.id!,
      );
      pendingMap[invoice.id!] = [...(pendingMap[invoice.id!] ?? []), op];
      emit(state.copyWith(pendingItemOps: pendingMap, error: e.toString()));
      _globalPending.add(op);
    }
  }

  Future<void> _onUpdateItem(UpdateItem event, Emitter<PosState> emit) async {
    final localId = event.localItemId;
    final itemNew = event.newItem;
    final invoice = state.activeInvoice;
    if (invoice == null) return;

    final list = state.activeInvoice!.items;
    final idx = list.indexWhere((it) => it.id == localId);
    if (idx == -1) return;
    final item = list[idx];
    list[idx] = itemNew;
    state.activeInvoice!.items = list;
    emit(state.copyWith());

    // if item has a server id (positive) try update immediately
    if ((item.id ?? 0) > 0) {
      try {
        await itemService.update(item.id!, item);
      } catch (e) {
        final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
          state.pendingItemOps,
        );
        final op = PendingOperation<SaleItem>(
          type: PendingOpType.update,
          item: item,
          localInvoiceId: invoice.id!,
        );
        pendingMap[invoice.id!] = [...(pendingMap[invoice.id!] ?? []), op];
        emit(state.copyWith(pendingItemOps: pendingMap, error: e.toString()));
        _globalPending.add(op);
      }
    } else {
      // item not synced yet. pending create will include updated quantity when it runs.
    }
  }

  Future<void> _onRemoveItem(
    RemoveItemFromActiveInvoice event,
    Emitter<PosState> emit,
  ) async {
    final localId = event.localItemId;
    final invoice = state.activeInvoice;
    if (invoice == null) return;
    final list = state.activeInvoice!.items;
    final idx = list.indexWhere((it) => it.id == localId);
    if (idx == -1) return;

    final item = list.removeAt(idx);
    state.activeInvoice!.items = list;
    emit(state.copyWith());

    if ((item.id ?? 0) > 0) {
      try {
        await itemService.delete(item.id!);
      } catch (e) {
        final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
          state.pendingItemOps,
        );
        final op = PendingOperation<SaleItem>(
          type: PendingOpType.delete,
          item: item,
          localInvoiceId: invoice.id!,
        );
        pendingMap[invoice.id!] = [...(pendingMap[invoice.id!] ?? []), op];
        emit(state.copyWith(pendingItemOps: pendingMap, error: e.toString()));
        _globalPending.add(op);
      }
    } else {
      // remove any pending create for this temp item
      final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
        state.pendingItemOps,
      );
      pendingMap[invoice.id!] = (pendingMap[invoice.id!] ?? []).where((op) {
        return !(op.type == PendingOpType.create && op.item.id == item.id);
      }).toList();
      emit(state.copyWith(pendingItemOps: pendingMap));
      _globalPending.removeWhere(
        (op) => op is PendingOperation<SaleItem> && op.item.id == item.id,
      );
    }
  }

  // -------- Pending processor --------
  Future<void> _processPending() async {
    if (_globalPending.isEmpty) return;

    // iterate over a snapshot to avoid concurrent-modification problems
    final queue = List<PendingOperation<dynamic>>.from(_globalPending);

    for (final baseOp in queue) {
      try {
        // SaleItem ops
        if (baseOp is PendingOperation<SaleItem>) {
          final op = baseOp as PendingOperation<SaleItem>;

          if (op.type == PendingOpType.create) {
            // try create on server
            final created = await itemService.create(op.item);

            // find invoice by id (don't use invoiceId as list index)
            final invIndex = state.invoices.indexWhere(
              (inv) => inv.id == op.localInvoiceId,
            );

            if (invIndex != -1) {
              final invoices = List<SaleInvoice>.from(state.invoices);
              final items = List<SaleItem>.from(invoices[invIndex].items);
              final updated = items
                  .map((it) => it.id == op.item.id ? created : it)
                  .toList();
              invoices[invIndex].items = updated;
              emit(state.copyWith(invoices: invoices, error: null));
            } else {
              // invoice not found: optionally reload invoices from server
            }

            // remove op from both runtime queue and state.pendingItemOps
            _globalPending.remove(op);
            final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
              state.pendingItemOps,
            );
            pendingMap[op
                .localInvoiceId] = (pendingMap[op.localInvoiceId] ?? [])
                .where((p) => !(p.type == op.type && p.item.id == op.item.id))
                .toList();
            emit(state.copyWith(pendingItemOps: pendingMap, error: null));
          } else if (op.type == PendingOpType.update) {
            final it = op.item;
            await itemService.update(it.id!, it);
            _globalPending.remove(op);
            final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
              state.pendingItemOps,
            );
            pendingMap[op
                .localInvoiceId] = (pendingMap[op.localInvoiceId] ?? [])
                .where((p) => !(p.type == op.type && p.item.id == op.item.id))
                .toList();
            emit(state.copyWith(pendingItemOps: pendingMap, error: null));
          } else if (op.type == PendingOpType.delete) {
            final it = op.item;
            await itemService.delete(it.id!);
            // remove item from invoice in state if present
            final invIndex = state.invoices.indexWhere(
              (inv) => inv.id == op.localInvoiceId,
            );
            if (invIndex != -1) {
              final invoices = List<SaleInvoice>.from(state.invoices);
              invoices[invIndex].items = invoices[invIndex].items
                  .where((x) => x.id != it.id)
                  .toList();
              emit(state.copyWith(invoices: invoices, error: null));
            }
            _globalPending.remove(op);
            final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
              state.pendingItemOps,
            );
            pendingMap[op
                .localInvoiceId] = (pendingMap[op.localInvoiceId] ?? [])
                .where((p) => !(p.type == op.type && p.item.id == op.item.id))
                .toList();
            emit(state.copyWith(pendingItemOps: pendingMap));
          }
        }
        // SaleInvoice ops (keep existing logic but use snapshot iteration)
        else if (baseOp is PendingOperation<SaleInvoice>) {
          final inv = baseOp.item;
          final created = await invoiceService.create(inv);
          final invoices = List<SaleInvoice>.from(state.invoices);
          final idx = invoices.indexWhere((i) => i.id == inv.id);
          if (idx != -1) {
            final migrated = invoices[idx].items.map((it) {
              it.invoiceId = created.id!;
              return it;
            }).toList();
            created.items = migrated;
            invoices[idx] = created;
          }
          _globalPending.remove(baseOp);
          emit(state.copyWith(invoices: invoices, activeInvoice: created));
          // emit
        }
      } catch (e) {
        // keep op for retry later
      }
    }
  }
}
