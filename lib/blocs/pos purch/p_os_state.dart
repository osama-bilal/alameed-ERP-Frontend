part of 'p_os_bloc.dart';

// Pending operation type
enum PendingOpType { create, update, delete }

class PendingOperation<T> {
  final PendingOpType type;
  final T item;
  final int localInvoiceId;
  PendingOperation({
    required this.type,
    required this.item,
    required this.localInvoiceId,
  });
}

class PosPurchState extends Equatable {
  static const _sentinel = Object();
  final List<PurchaseInvoice> invoices;
  final PurchaseInvoice? activeInvoice;
  final Map<int, List<PendingOperation<PurchaseItem>>> pendingItemOps;
  final List<ProductCategory> categories;
  // final List<POSView> products;
  final bool loading;
  final String? error;
  final int trigger;

  PosPurchState({
    this.invoices = const [],
    this.activeInvoice,
    Map<int, List<PurchaseItem>>? invoiceItems,
    Map<int, List<PendingOperation<PurchaseItem>>>? pendingItemOps,
    this.categories = const [],
    // this.products = const [],
    this.loading = true,
    this.error,
    required this.trigger,
  }) : pendingItemOps = pendingItemOps ?? {};

  PosPurchState copyWith({
    List<PurchaseInvoice>? invoices,
    Object? activeInvoice = _sentinel,
    Map<int, List<PendingOperation<PurchaseItem>>>? pendingItemOps,
    List<ProductCategory>? categories,
    // List<POSView>? products,
    bool? loading,
    String? error,
    Object? sellInvoice = _sentinel,
    bool isPrinting = false,
    required int trigger,
  }) {
    return PosPurchState(
      invoices: invoices ?? this.invoices,
      activeInvoice: identical(activeInvoice, _sentinel)
          ? this.activeInvoice
          : activeInvoice as PurchaseInvoice?, // ممكن null أو قيمة
      pendingItemOps: pendingItemOps ?? this.pendingItemOps,
      categories: categories ?? this.categories,
      // products: products ?? this.products,
      loading: loading ?? this.loading,
      error: error,
      trigger: trigger,
    );
  }

  PosPurchState reset() => PosPurchState(trigger: 0);
  @override
  List<Object?> get props => [
    invoices,
    activeInvoice,
    pendingItemOps,
    categories,
    // products,
    loading,
    error,
    trigger,
  ];
}
