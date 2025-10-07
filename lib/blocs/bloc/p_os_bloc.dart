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
    Timer.periodic(Duration(seconds: 5), (_) => _processPending());
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
      final items = await itemService.fetchList(
        queryParams: {"invoice": invoice.id},
      );
      final newMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
      newMap[invoice.id!] = items;
      emit(
        state.copyWith(
          invoiceItems: newMap,
          loading: false,
          activeInvoice: invoice,
        ),
      );
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
    // create local invoice with temporary negative id
    final tempId = -(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final local = SaleInvoice(
      id: tempId,
      status: 'draft',
      refundStatus: 'not_refunded',
      subtotal: '0.00',
      tax: '0.00',
      discount: '0.00',
      total: '0.00',
      paid: '0.00',
      date: DateTime.now(),
    );

    final newInvoices = [local, ...state.invoices];
    emit(state.copyWith(invoices: newInvoices, activeInvoice: local));

    // try to create on server
    try {
      final created = await invoiceService.create(local);
      // replace temp invoice with server invoice
      final idx = newInvoices.indexWhere((i) => i.id == tempId);
      if (idx != -1) {
        newInvoices[idx] = created;
      }

      // migrate items map from tempId to real id if any
      final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
      if (itemsMap.containsKey(tempId)) {
        final items = itemsMap.remove(tempId)!;
        // update invoiceId on items
        final migrated = items.map((it) {
          it.invoiceId = created.id!;
          return it;
        }).toList();
        itemsMap[created.id!] = migrated;
      }

      // update pending ops to point to real invoice id
      final pending = Map<int, List<PendingOperation<SaleItem>>>.from(
        state.pendingItemOps,
      );
      if (pending.containsKey(tempId)) {
        final ops = pending.remove(tempId)!;
        final migratedOps = ops
            .map(
              (op) => PendingOperation<SaleItem>(
                type: op.type,
                item: op.item,
                localInvoiceId: created.id!,
              ),
            )
            .toList();
        pending[created.id!] = [
          ...(pending[created.id!] ?? []),
          ...migratedOps,
        ];
      }

      emit(
        state.copyWith(
          invoices: newInvoices,
          invoiceItems: itemsMap,
          pendingItemOps: pending,
          activeInvoice: created,
        ),
      );
    } catch (e) {
      // keep local invoice and schedule retry
      _globalPending.add(
        PendingOperation<SaleInvoice>(
          type: PendingOpType.create,
          item: local,
          localInvoiceId: local.id!,
        ),
      );
      emit(state.copyWith(error: e.toString(), activeInvoice: local));
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
    final tempItemId = -(DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final item = SaleItem(
      id: tempItemId,
      variantId: product.id,
      quantity: 1,
      unitPrice: product.price.toString(),
      invoiceId: invoice.id!,
    );

    final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
    final listForInvoice = [...(itemsMap[invoice.id!] ?? []), item];
    itemsMap[invoice.id!] = listForInvoice;

    emit(state.copyWith(invoiceItems: itemsMap));

    // try to create on server immediately
    try {
      final created = await itemService.create(item);
      // replace temp item with created item
      final updated = itemsMap[invoice.id!]!
          .map((it) => it.id == tempItemId ? created : it)
          .toList();
      itemsMap[invoice.id!] = updated;
      emit(state.copyWith(invoiceItems: itemsMap));
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

    final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
    final list = itemsMap[invoice.id!] ?? [];
    final idx = list.indexWhere((it) => it.id == localId);
    if (idx == -1) return;
    final item = list[idx];
    // item = ItemNew;
    list[idx] = itemNew;
    itemsMap[invoice.id!] = list;
    emit(state.copyWith(invoiceItems: itemsMap));

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
    final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
    final list = itemsMap[invoice.id!] ?? [];
    final idx = list.indexWhere((it) => it.id == localId);
    if (idx == -1) return;

    final item = list.removeAt(idx);
    itemsMap[invoice.id!] = list;
    emit(state.copyWith(invoiceItems: itemsMap));

    // if item had server id, delete on server; otherwise remove pending create if exists
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

    // snapshot queue
    final queue = List.from(_globalPending);
    for (final op in queue) {
      try {
        if (op is PendingOperation<SaleItem>) {
          if (op.type == PendingOpType.create) {
            final created = await itemService.create(op.item);
            // update state mapping: replace temp id with real id
            final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
            final list = itemsMap[op.localInvoiceId] ?? [];
            final updated = list
                .map((it) => it.id == op.item.id ? created : it)
                .toList();
            itemsMap[op.localInvoiceId] = updated;
            _globalPending.remove(op);
            add(
              SetActiveInvoice(state.activeInvoice!),
            ); // refresh UI for active invoice
            emit(state.copyWith(invoiceItems: itemsMap));
          } else if (op.type == PendingOpType.update) {
            final it = op.item;
            await itemService.update(it.id!, it);
            _globalPending.remove(op);
          } else if (op.type == PendingOpType.delete) {
            final it = op.item;
            await itemService.delete(it.id!);
            _globalPending.remove(op);
          }
        } else if (op is PendingOperation<SaleInvoice>) {
          // try invoice create
          final inv = op.item;
          final created = await invoiceService.create(inv);
          // replace in invoices list and migrate items
          final invoices = List<SaleInvoice>.from(state.invoices);
          final idx = invoices.indexWhere((i) => i.id == inv.id);
          if (idx != -1) invoices[idx] = created;
          final itemsMap = Map<int, List<SaleItem>>.from(state.invoiceItems);
          if (itemsMap.containsKey(inv.id)) {
            final items = itemsMap.remove(inv.id)!;
            final migrated = items.map((it) {
              it.invoiceId = created.id!;
              return it;
            }).toList();
            itemsMap[created.id!] = migrated;
          }
          _globalPending.remove(op);
          emit(
            state.copyWith(
              invoices: invoices,
              invoiceItems: itemsMap,
              activeInvoice: created,
            ),
          );
        }
      } catch (e) {
        // leave op in queue to retry later
      }
    }
  }
}
