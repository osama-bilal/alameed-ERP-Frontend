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

// State
class PosState extends Equatable {
  static const _sentinel = Object();
  final List<SaleInvoice> invoices;
  final SaleInvoice? activeInvoice;
  final SaleInvoice? sellInvoice;
  final Map<int, List<PendingOperation<SaleItem>>> pendingItemOps;
  final List<ProductCategory> categories;
  final List<POSView> products;
  final bool loading;
  final String? error;
  final int trigger;
  final bool printingInvoice;

  PosState({
    this.invoices = const [],
    this.activeInvoice,
    this.sellInvoice,
    Map<int, List<SaleItem>>? invoiceItems,
    Map<int, List<PendingOperation<SaleItem>>>? pendingItemOps,
    this.categories = const [],
    this.products = const [],
    this.loading = true,
    this.printingInvoice = false,
    this.error,
    required this.trigger,
  }) : pendingItemOps = pendingItemOps ?? {};

  PosState copyWith({
    List<SaleInvoice>? invoices,
    Object? activeInvoice = _sentinel,
    Map<int, List<PendingOperation<SaleItem>>>? pendingItemOps,
    List<ProductCategory>? categories,
    List<POSView>? products,
    bool? loading,
    String? error,
    Object? sellInvoice = _sentinel,
    bool isPrinting = false,
    required int trigger,
  }) {
    return PosState(
      invoices: invoices ?? this.invoices,
      activeInvoice: identical(activeInvoice, _sentinel)
          ? this.activeInvoice
          : activeInvoice as SaleInvoice?, // ممكن null أو قيمة
      sellInvoice: identical(sellInvoice, _sentinel)
          ? this.sellInvoice
          : sellInvoice as SaleInvoice?,
      pendingItemOps: pendingItemOps ?? this.pendingItemOps,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      loading: loading ?? this.loading,
      printingInvoice: isPrinting,
      error: error,
      trigger: trigger,
    );
  }

  PosState reset() => PosState(trigger: 0);
  @override
  List<Object?> get props => [
    invoices,
    activeInvoice,
    pendingItemOps,
    categories,
    products,
    loading,
    error,
    trigger,
  ];
}
