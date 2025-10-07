// here is set the shared preferences and other main things like database and api services and constants and colors, styles
part of 'main.dart';

class AppService {
  static final saleInvoiceService = GeneralService<SaleInvoice>(
    endpoint: AppUrls.saleInvoiceUrl,
    fromMap: SaleInvoice.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final saleItemService = GeneralService<SaleItem>(
    endpoint: AppUrls.saleItemUrl,
    fromMap: SaleItem.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final returnSaleService = GeneralService<ReturnSale>(
    endpoint: AppUrls.returnSaleItemUrl,
    fromMap: ReturnSale.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final attendanceService = GeneralService<Attendance>(
    endpoint: AppUrls.attendanceUrl,
    toMap: (o) => o.toMap(),
    fromMap: (o) => Attendance.fromMap(o),
  );

  static final customerService = GeneralService<Customer>(
    endpoint: AppUrls.customerUrl,
    fromMap: Customer.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final debtPaymentService = GeneralService<DebtPayment>(
    endpoint: AppUrls.debtPaymentsUrl,
    fromMap: DebtPayment.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final debtService = GeneralService<Debt>(
    endpoint: AppUrls.debtUrl,
    fromMap: Debt.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final employeeService = GeneralService<Employee>(
    endpoint: AppUrls.employeeUrl,
    fromMap: Employee.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final expenseService = GeneralService<Expense>(
    endpoint: AppUrls.expenseUrl,
    fromMap: Expense.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final payMethodService = GeneralService<PaymentMethod>(
    endpoint: AppUrls.paymentMethodUrl,
    fromMap: PaymentMethod.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final salaryService = GeneralService<SalaryPayment>(
    endpoint: AppUrls.salaryPaymentUrl,
    fromMap: SalaryPayment.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final productService = GeneralService<Product>(
    endpoint: AppUrls.productUrl,
    fromMap: Product.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final variantService = GeneralService<ProductVariant>(
    endpoint: AppUrls.variantUrl,
    fromMap: ProductVariant.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final optionTypeService = GeneralService<OptionsType>(
    endpoint: AppUrls.optionTypesUrl,
    fromMap: OptionsType.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final optionValueService = GeneralService<OptionsValue>(
    endpoint: AppUrls.optionValueUrl,
    fromMap: OptionsValue.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final categoryService = GeneralService<ProductCategory>(
    endpoint: AppUrls.categoryUrl,
    fromMap: ProductCategory.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final brandService = GeneralService<Brand>(
    endpoint: AppUrls.brandUrl,
    fromMap: Brand.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final purchaseInvoiceService = GeneralService<PurchaseInvoice>(
    endpoint: AppUrls.purchaseInvoiceUrl,
    fromMap: PurchaseInvoice.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final purchaseItemService = GeneralService<PurchaseItem>(
    endpoint: AppUrls.purchaseItemUrl,
    fromMap: PurchaseItem.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final returnPurchaseService = GeneralService<ReturnPurchase>(
    endpoint: AppUrls.returnPurchaseUrl,
    fromMap: ReturnPurchase.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final reportService = GeneralService<Report>(
    endpoint: AppUrls.reportUrl,
    fromMap: Report.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final shiftService = GeneralService<Shift>(
    endpoint: AppUrls.shiftUrl,
    fromMap: Shift.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final stockService = GeneralService<StockMovement>(
    endpoint: AppUrls.stockMovementUrl,
    fromMap: StockMovement.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final supplierService = GeneralService<Supplier>(
    endpoint: AppUrls.supplierUrl,
    fromMap: Supplier.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final accountTransactionService = GeneralService<AccountTransaction>(
    endpoint: AppUrls.accountTransactionUrl,
    fromMap: AccountTransaction.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final usersService = GeneralService<User>(
    endpoint: AppUrls.userUrl,
    fromMap: User.fromMap,
    toMap: (o) => o.toMap(),
  );

  static final posViewService = GeneralService<POSView>(
    endpoint: AppUrls.productsViewUrl,
    fromMap: POSView.fromMap,
    toMap: (o) => o.toMap(),
  );
}
