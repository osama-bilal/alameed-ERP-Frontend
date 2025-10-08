part of 'p_os_bloc.dart';

// Pending operation type
enum PendingOpType { create, update, delete }

class PendingOperation<T> {
  final PendingOpType type;
  final T item;
  final int
  localInvoiceId; // invoice that this op belongs to (could be temp id)

  PendingOperation({
    required this.type,
    required this.item,
    required this.localInvoiceId,
  });
}

// State
class PosState extends Equatable {
  final List<SaleInvoice> invoices;
  final SaleInvoice? activeInvoice;
  // final Map<int, List<SaleItem>> invoiceItems;
  // invoiceId -> items
  final Map<int, List<PendingOperation<SaleItem>>> pendingItemOps;
  // invoiceId -> pending ops
  final List<ProductCategory> categories;
  final List<POSView> products;
  final bool loading;
  final String? error;

  PosState({
    this.invoices = const [],
    this.activeInvoice,
    Map<int, List<SaleItem>>? invoiceItems,
    Map<int, List<PendingOperation<SaleItem>>>? pendingItemOps,
    this.categories = const [],
    this.products = const [],
    this.loading = false,
    this.error,
  }) : 
  // invoiceItems = invoiceItems ?? {},
       pendingItemOps = pendingItemOps ?? {};

  PosState copyWith({
    List<SaleInvoice>? invoices,
    SaleInvoice? activeInvoice,
    // Map<int, List<SaleItem>>? invoiceItems,
    Map<int, List<PendingOperation<SaleItem>>>? pendingItemOps,
    List<ProductCategory>? categories,
    List<POSView>? products,
    bool? loading,
    String? error,
  }) {
    return PosState(
      invoices: invoices ?? this.invoices,
      activeInvoice: activeInvoice ?? this.activeInvoice,
      // invoiceItems: invoiceItems ?? this.invoiceItems,
      pendingItemOps: pendingItemOps ?? this.pendingItemOps,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    invoices,
    activeInvoice,
    // invoiceItems,
    pendingItemOps,
    categories,
    products,
    loading,
    error,
  ];
}
