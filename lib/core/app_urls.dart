// here is set the shared preferences and other main things like database and api services and constants and colors, styles
part of 'main.dart';

class AppUrls {
  static String get serverUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }
    return "http://192.168.8.110:8000";

  }

  static final saleInvoiceUrl = "/invoices/sales/";
  static final saleItemUrl = "/invoices/sale-items/";
  static final returnSaleItemUrl = "/invoices/returns/";
  static final paymentMethodUrl = "/invoices/payment-methods/";
  static final purchaseInvoiceUrl = "/invoices/purchase/";
  static final purchaseItemUrl = "/invoices/purchase-items/";
  static final returnPurchaseUrl = "/invoices/return-purchases/";
  static final debtUrl = "/debts/debts/";
  static final debtPaymentsUrl = "/debts/payments/";
  static final employeeUrl = "/employees/employees/";
  static final salaryPaymentUrl = "/employees/salary-payments/";
  static final attendanceUrl = "/employees/attendances/";
  static final accountTransactionUrl = "/expenses/accounts/";
  static final depositUrl = "/expenses/deposits/";
  static final expenseUrl = "/expenses/expenses/";
  static final productsViewUrl = "/products/pos/";
  static final productUrl = "/products/products/";
  static final variantUrl = "/products/variants/";
  static final optionTypesUrl = "/products/types/";
  static final optionValueUrl = "/products/values/";
  static final categoryUrl = "/products/category/";
  static final brandUrl = "/products/brand/";
  static final stockMovementUrl = "/products/stock-movements/";
  static final reportUrl = "/reports/";
  static final customerUrl = "/users/customers/";
  static final supplierUrl = "/users/suppliers/";
  static final userUrl = "/users/user/";
  static final shiftUrl = "/users/shifts/";
}
