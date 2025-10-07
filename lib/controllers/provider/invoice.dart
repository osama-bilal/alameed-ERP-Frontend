import 'package:flutter/foundation.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class InvoiceProvider extends ChangeNotifier {
  final Map<int, SaleInvoice> _invoices = {}; // جميع الفواتير
  int? _activeInvoiceId;

  // إنشاء فاتورة جديدة
  void createNewInvoice() {
    final newId = DateTime.now().millisecondsSinceEpoch; // رقم فريد
    _invoices[newId] = SaleInvoice(id: newId);
    _activeInvoiceId = newId;
    notifyListeners();
  }

  // تعيين فاتورة نشطة
  void setActiveInvoice(int id) {
    if (_invoices.containsKey(id)) {
      _activeInvoiceId = id;
      notifyListeners();
    }
  }

  void addInvoice(SaleInvoice i) {
    _invoices[i.id!] = i;
    // notifyListeners();
  }

  set invoices(Map<int, SaleInvoice> il) {
    _invoices.clear();
    _invoices.addAll(il);
    // notifyListeners();
  }

  SaleInvoice? get activeInvoice =>
      _activeInvoiceId != null ? _invoices[_activeInvoiceId] : null;

  List<SaleInvoice> get allInvoices => _invoices.values.toList();

  int? get activeInvoiceId => _activeInvoiceId;

  // العمليات على الفاتورة النشطة:
  void setCustomer(int customerId) {
    if (activeInvoice != null) {
      activeInvoice!.customerId = customerId;
      notifyListeners();
    }
  }

  void setActive(SaleInvoice invoice) {
    _activeInvoiceId = invoice.id;
  }

  void addItem(SaleItem item) {
    if (activeInvoice != null) {
      activeInvoice!.items.add(item);
      notifyListeners();
    }
  }

  void removeItem(int id) {
    if (activeInvoice != null) {
      activeInvoice!.items.removeWhere((element) => element.id == id);
      notifyListeners();
    }
  }

  void setItems(List<SaleItem> items) {
    if (activeInvoice != null) {
      activeInvoice!.items = items;
      // notifyListeners();
    }
  }

  double get total => activeInvoice?.totals ?? 0.0;

  void clearActiveInvoice() {
    if (_activeInvoiceId != null) {
      _invoices.remove(_activeInvoiceId);
      _activeInvoiceId = null;
      notifyListeners();
    }
  }
}
