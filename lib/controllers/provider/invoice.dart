import 'package:flutter/foundation.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class SellingProvider extends ChangeNotifier {
  SaleInvoice? _invoice; // جميع الفواتير
  SaleInvoice? get invoice => _invoice;
  // تعيين فاتورة نشطة
  void setActive(SaleInvoice invoice) {
    _invoice = invoice;
    // notifyListeners();
  }

  void setDiscount(String d) {
    _invoice?.discount = d;
    // notifyListeners();
  }

  void setTax(String t) {
    _invoice?.tax = t;
    // notifyListeners();
  }

  void setPaid(String p) {
    _invoice?.paid = p;
    // notifyListeners();
  }

  // العمليات على الفاتورة النشطة:
  void setCustomer(int customerId) {
    if (_invoice != null) {
      _invoice!.customerId = customerId;
      // notifyListeners();
    }
  }

  void addItem(SaleItem item) {
    if (_invoice != null) {
      _invoice!.items.add(item);
      // notifyListeners();
    }
  }

  void removeItem(int id) {
    if (_invoice != null) {
      _invoice!.items.removeWhere((element) => element.id == id);
      // notifyListeners();
    }
  }

  void setItems(List<SaleItem> items) {
    if (_invoice != null) {
      _invoice!.items = items;
      // notifyListeners();
    }
  }

  void setPayMethod(int? id) {
    _invoice?.paymentMethodId = id;
    // notifyListeners();
  }

  double get total => _invoice?.totals ?? 0.0;

  void clearInvoice() {
    if (_invoice != null) {
      _invoice = null;
      notifyListeners();
    }
  }

  void save() {
    _invoice = _invoice;
    notifyListeners();
  }
}
