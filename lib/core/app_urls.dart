// here is set the shared preferences and other main things like database and api services and constants and colors, styles
part of 'main.dart';

class AppUrls {
  static final accountTransactionUrl = "/expenses/accounts/";
  static final attendanceUrl = "/employees/attendances/";
  static final brandUrl = "/products/brand/";
  static final categoryUrl = "/products/category/";
  static final customerUrl = "/users/customers/";
  static final debtUrl = "/debts/debts/";
  static final debtPaymentsUrl = "/debts/payments/";
  static final depositUrl = "/expenses/deposits/";
  static final expenseUrl = "/expenses/expenses/";
  static final employeeUrl = "/employees/employees/";
  static final optionTypesUrl = "/products/types/";
  static final optionValueUrl = "/products/values/";
  static final paymentMethodUrl = "/invoices/payment-methods/";
  static final posViewUrl = "/products/pos/";
  static final productUrl = "/products/products/";
  static final purchaseInvoiceUrl = "/invoices/purchase/";
  static final purchaseItemUrl = "/invoices/purchase-items/";
  static final reportUrl = "/reports/";
  static final returnSaleItemUrl = "/invoices/returns/";
  static final returnPurchaseUrl = "/invoices/return-purchases/";
  static final saleInvoiceUrl = "/invoices/sales/";
  static final saleItemUrl = "/invoices/sale-items/";
  static final salaryPaymentUrl = "/employees/salary-payments/";
  static final shiftUrl = "/users/shifts/";
  static final stockMovementUrl = "/products/stock-movements/";
  static final supplierUrl = "/users/suppliers/";
  static final variantUrl = "/products/variants/";
  static final userUrl = "/users/user/";
  static final groupsUrl = "/users/groups/";
  static String get serverUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }
    return "http://127.0.0.1:8000";
  }
}
