import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'dart:async';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/services/api_client.dart';
import 'package:ponit_of_sales/services/custom_failures.dart';
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

  PosBloc() : super(PosState(trigger: 0)) {
    on<LoadPosData>(_onLoad);
    on<SetActiveInvoice>(_onSetActiveInvoice);
    on<CreateNewInvoice>(_onCreateNewInvoice);
    on<AddProductToActiveInvoice>(_onAddProduct);
    on<UpdateItem>(_onUpdateItem);
    on<RemoveItemFromActiveInvoice>(_onRemoveItem);
    on<FinalizeActiveInvoice>(_finalizeActiveInvoice);
    on<PaySellInvoice>(_paySell);
    on<SetUnpaidSell>(_sellUnpaid);
    on<CancelSell>(_cancelSell);
    on<UpdateSellInvoice>(_updateSell);
    on<Reset>(_reset);
    on<SaveAnd>(_saveAnd);
    // try to process pending ops periodically
    Timer.periodic(Duration(seconds: 5), (_) => _processPending());
  }

  // ------------ RESET ---------------
  Future<void> _reset(Reset event, Emitter<PosState> emit) async {
    emit(state.reset());
  }

  Future<void> _saveAnd(SaveAnd event, Emitter<PosState> emit) async {
    final sell = state.sellInvoice;
    if (sell == null) return;
    add(UpdateSellInvoice(id: sell.id!, invoice: event.invoice));
    // await Future.delayed(Duration(milliseconds: 500));
    emit(state.copyWith(trigger: state.trigger + 1));
    add(event.thenGo);
  }

  // ------------- Finalize active invoice ----------------
  Future<void> _finalizeActiveInvoice(
    FinalizeActiveInvoice event,
    Emitter<PosState> emit,
  ) async {
    final invoice = state.activeInvoice;
    if (invoice == null) return;
    emit(
      state.copyWith(
        loading: true,
        trigger: state.trigger + 1,
        activeInvoice: invoice,
      ),
    );
    if ((invoice.id ?? 0) > 0) {
      final api = ApiClient();
      try {
        final response = await api.dio.post(
          "${AppUrls.saleInvoiceUrl}${invoice.id}/finalize/",
        );
        if (response.data['status'] == "تم اعتماد الفاتورة") {
          final invoices = List<SaleInvoice>.from(state.invoices);
          final idx = invoices.indexWhere((i) => i.id == invoice.id);
          if (idx != -1) {
            invoices.removeAt(idx);
            invoice.status = "final";
            emit(
              state.copyWith(
                invoices: invoices,
                activeInvoice: null,
                loading: false,
                sellInvoice: invoice,
                trigger: 100,
              ),
            );
          }
        }
      } catch (e) {
        emit(
          state.copyWith(
            trigger: state.trigger + 3,
            error: e.toString(),
            activeInvoice: invoice,
            loading: false,
          ),
        );

        // throw Exception("Error While finalizing the invoice,\nError: $e");
      }
    }
  }

  // ---------- PaySellInvoice ------------
  Future<void> _paySell(PaySellInvoice event, Emitter<PosState> emit) async {
    final sell = state.sellInvoice;
    if (sell == null) return;
    emit(
      state.copyWith(
        loading: true,
        sellInvoice: sell,
        trigger: state.trigger + 1,
      ),
    );
    var amount = event.amount;
    if (amount == "") {
      amount = "0.00";
    }
    if ((sell.id ?? 0) > 0) {
      final api = ApiClient();
      try {
        final response = await api.dio.post(
          "${AppUrls.saleInvoiceUrl}${sell.id}/mark_paid/",
          data: <String, dynamic>{"paid": amount},
        );
        if (response.data['status'] != null) {
          final paidInvoice = await invoiceService.fetchItem(sell.id);

          // sell.status = "paid";
          if (['paid', 'partially_paid'].contains(paidInvoice.status)) {
            emit(
              state.copyWith(
                loading: false,
                sellInvoice: null,
                trigger: state.trigger + 2,
              ),
            );
          }
        }
      } catch (e) {
        emit(
          state.copyWith(
            trigger: state.trigger + 1,
            error: e.toString(),
            sellInvoice: sell,
            loading: false,
          ),
        );
        // throw Exception("Error While mark invoice paid,\nError: $e");
      }
    }
  }

  // ---------- Set Sell Invocie Unpaid -------------
  Future<void> _sellUnpaid(SetUnpaidSell event, Emitter<PosState> emit) async {
    final sell = state.sellInvoice;
    if (sell == null) return;
    emit(
      state.copyWith(
        sellInvoice: sell,
        trigger: state.trigger + 1,
        loading: true,
      ),
    );
    if ((sell.id ?? 0) > 10) {
      final api = ApiClient();
      try {
        final response = await api.dio.post(
          "${AppUrls.saleInvoiceUrl}${sell.id}/mark_unpaid/",
        );
        if (response.data['status'] != null) {
          emit(
            state.copyWith(
              sellInvoice: null,
              loading: false,
              trigger: state.trigger + 2,
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(
            trigger: state.trigger + 1,
            error: e.toString(),
            sellInvoice: sell,
            loading: false,
          ),
        );

        // throw Exception("Error While mark invoice unpaid,\nError: $e");
      }
    }
  }

  // ----------- Cancel Sell Invoice ----------------
  Future<void> _cancelSell(CancelSell event, Emitter<PosState> emit) async {
    final sell = state.sellInvoice;
    if (sell == null) return;
    emit(
      state.copyWith(
        sellInvoice: sell,
        trigger: state.trigger + 1,
        loading: true,
      ),
    );
    if ((sell.id ?? 0) > 10) {
      final api = ApiClient();
      try {
        final response = await api.dio.post(
          "${AppUrls.saleInvoiceUrl}${sell.id}/cancel/",
        );
        if (response.data['status'] != null) {
          emit(
            state.copyWith(
              loading: false,
              trigger: state.trigger + 2,
              sellInvoice: null,
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(
            trigger: state.trigger + 1,
            error: e.toString(),
            sellInvoice: sell,
            loading: false,
          ),
        );

        // throw Exception("Error While cancel invoice $id,\nError: $e");
      }
    }
  }

  // ----------- Update Sell Invoice Like setting customer, discount,
  Future<void> _updateSell(
    UpdateSellInvoice event,
    Emitter<PosState> emit,
  ) async {
    final sell = state.sellInvoice;
    if (sell == null) return;
    final invId = event.id;
    final newInv = event.invoice;
    emit(state.copyWith(trigger: state.trigger + 1, loading: true));

    try {
      final updated = await invoiceService.patch(invId, newInv.toMap());
      emit(
        state.copyWith(
          trigger: state.trigger + 2,
          loading: false,
          sellInvoice: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          trigger: state.trigger + 1,
          loading: false,
          sellInvoice: sell,
        ),
      );
    }
  }

  // -------- Handlers --------
  Future<void> _onLoad(LoadPosData event, Emitter<PosState> emit) async {
    emit(state.copyWith(loading: true, activeInvoice: null, trigger: 1));
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
          trigger: state.trigger + 1,
        ),
      );
      if (invoices.isNotEmpty) add(SetActiveInvoice(invoices.first));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          trigger: state.trigger + 1,
        ),
      );
    }
  }

  Future<void> _onSetActiveInvoice(
    SetActiveInvoice event,
    Emitter<PosState> emit,
  ) async {
    final invoice = event.invoice;
    emit(state.copyWith(activeInvoice: invoice, trigger: state.trigger + 1));
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
    emit(
      state.copyWith(
        invoices: newInvoices,
        activeInvoice: localInvoice,
        trigger: state.trigger + 1,
      ),
    );

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
          trigger: state.trigger + 2,
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
      emit(
        state.copyWith(trigger: state.trigger + 1, activeInvoice: localInvoice),
      );
    }
  }

  Future<void> _onAddProduct(
    AddProductToActiveInvoice event,
    Emitter<PosState> emit,
  ) async {
    var invoice = state.activeInvoice;
    if (invoice == null) return;
    // create a local invoice first
    // add(CreateNewInvoice());
    // // wait a tick then try again

    // await Future.delayed(Duration(milliseconds: 100));
    // invoice = state.activeInvoice;
    // if (invoice == null) return;
    // // abort if still null
    // if ((invoice.id ?? 0) > 0) {
    //   add(AddProductToActiveInvoice(event.product));
    // }
    // }

    final product = event.product;

    final list = state.activeInvoice!.items;
    final idx = list.indexWhere((it) => it.variantId == product.id);
    if (idx != -1) {
      final item = list[idx];
      item.quantity++;
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
      emit(
        state.copyWith(
          invoices: invoices,
          trigger: state.trigger + 1,
          activeInvoice: invoice,
        ),
      );
    }

    // try to create on server immediately
    try {
      final created = await itemService.create(item);
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
        emit(
          state.copyWith(
            invoices: invoices,
            activeInvoice: invoices[invIndex],
            trigger: state.trigger + 2,
          ),
        );
      }
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

      emit(
        state.copyWith(
          pendingItemOps: pendingMap,
          trigger: state.trigger + 2,
          activeInvoice: invoice,
        ),
      );
      _globalPending.add(op);
    }
  }

  Future<void> _onUpdateItem(UpdateItem event, Emitter<PosState> emit) async {
    final localId = event.localItemId;
    final itemNew = event.newItem;
    final invoice = state.activeInvoice;
    if (invoice == null) return;

    final invIndex = state.invoices.indexWhere((inv) => inv.id == invoice.id!);

    if (invIndex != -1) {
      final invoices = List<SaleInvoice>.from(state.invoices);
      final items = List<SaleItem>.from(invoices[invIndex].items);
      final updated = items
          .map((it) => it.id == localId ? itemNew : it)
          .toList();
      invoices[invIndex].items = updated;
      emit(
        state.copyWith(
          invoices: invoices,
          trigger: state.trigger + 1,
          activeInvoice: invoice,
        ),
      );
    }

    // if item has a server id (positive) try update immediately
    if (localId > 0) {
      try {
        await itemService.update(localId, itemNew);
      } catch (e) {
        final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
          state.pendingItemOps,
        );
        final op = PendingOperation<SaleItem>(
          type: PendingOpType.update,
          item: itemNew,
          localInvoiceId: invoice.id!,
        );
        pendingMap[invoice.id!] = [...(pendingMap[invoice.id!] ?? []), op];
        emit(
          state.copyWith(
            pendingItemOps: pendingMap,
            activeInvoice: invoice,
            trigger: state.trigger + 2,
          ),
        );
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
    final list = invoice.items;
    final idx = list.indexWhere((it) => it.id == localId);
    if (idx == -1) return;

    final item = list.removeAt(idx);
    invoice.items = list;
    emit(state.copyWith(trigger: state.trigger + 1, activeInvoice: invoice));

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
        emit(
          state.copyWith(
            pendingItemOps: pendingMap,
            trigger: state.trigger + 2,
            activeInvoice: invoice,
          ),
        );
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
      emit(
        state.copyWith(
          pendingItemOps: pendingMap,
          trigger: state.trigger + 1,
          activeInvoice: invoice,
        ),
      );
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
    // print("there is : ${_globalPending.length} proccess in queue");
    for (final baseOp in queue) {
      try {
        // SaleItem ops
        if (baseOp is PendingOperation<SaleItem>) {
          final op = baseOp;

          if (op.type == PendingOpType.create) {
            // try create on server
            final created = await itemService.create(op.item);

            // find invoice by id (don't use invoiceId as list index)
            final invIndex = state.invoices.indexWhere(
              (inv) => inv.id == op.item.invoiceId,
            );

            if (invIndex != -1) {
              final invoices = List<SaleInvoice>.from(state.invoices);
              final items = List<SaleItem>.from(invoices[invIndex].items);
              final updated = items
                  .map((it) => it.id == op.item.id ? created : it)
                  .toList();
              invoices[invIndex].items = updated;
              // ignore: invalid_use_of_visible_for_testing_member
              final pendingMap =
                  Map<int, List<PendingOperation<SaleItem>>>.from(
                    state.pendingItemOps,
                  );
              pendingMap.forEach((key, ops) {
                for (var p in ops) {
                  if (p.item.id == op.item.id) {
                    p.item.id = created.id!;
                  }
                }
              });
              emit(
                state.copyWith(invoices: invoices, trigger: state.trigger + 1),
              );
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
            emit(
              state.copyWith(
                pendingItemOps: pendingMap,
                trigger: state.trigger + 1,
              ),
            );
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
            emit(
              state.copyWith(
                pendingItemOps: pendingMap,
                trigger: state.trigger + 1,
              ),
            );
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
              emit(
                state.copyWith(invoices: invoices, trigger: state.trigger + 1),
              );
            }
            _globalPending.remove(op);
            final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
              state.pendingItemOps,
            );
            pendingMap[op
                .localInvoiceId] = (pendingMap[op.localInvoiceId] ?? [])
                .where((p) => !(p.type == op.type && p.item.id == op.item.id))
                .toList();
            emit(
              state.copyWith(
                pendingItemOps: pendingMap,
                trigger: state.trigger + 1,
              ),
            );
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
          final pendingMap = Map<int, List<PendingOperation<SaleItem>>>.from(
            state.pendingItemOps,
          );
          pendingMap.forEach((key, ops) {
            if (key == baseOp.localInvoiceId) {
              for (var p in ops) {
                // if (p.localInvoiceId == baseOp.localInvoiceId) {
                p.item.invoiceId = created.id!;
                // }
              }
            }
          });
          _globalPending.remove(baseOp);
          emit(
            state.copyWith(
              invoices: invoices,
              activeInvoice: created,
              trigger: state.trigger + 2,
              pendingItemOps: pendingMap,
            ),
          );
          // emit
        }
      } on NetworkFailure catch (f) {
        // 🚨 هنا تم التفريق: خطأ شبكة
        // emit(state.copyWith(trigger: state.trigger+1, error: 'Offline: ${f.message}'));
      } on ServerFailure catch (f) {
        // 🚨 هنا تم التفريق: خطأ سيرفر
        _globalPending.remove(baseOp);

        emit(
          state.copyWith(
            trigger: state.trigger + 1,
            error: 'Server Down (Code ${f.statusCode}): حاول لاحقاً.',
          ),
        );
        // emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
      } on ClientFailure catch (f) {
        // 🚨 هنا تم التفريق: خطأ عميل/منطق
        _globalPending.remove(baseOp);

        emit(
          state.copyWith(
            trigger: state.trigger + 1,
            error: 'Client Error (Code ${f.statusCode}): ${f.message}',
          ),
        );
      } catch (_) {
        emit(
          state.copyWith(
            trigger: state.trigger + 1,
            error: 'حدث خطأ غير متوقع.',
          ),
        );
      }
    }
  }
}
