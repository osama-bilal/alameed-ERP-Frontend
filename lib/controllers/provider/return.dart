import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class ReturnProvider extends ChangeNotifier {
  List<ReturnSaleProvider> items = [];
  SaleInvoice? invoice;

  void addReturn(ReturnSaleProvider item) {
    if (items.any((element) => element.saleItemId == item.saleItemId)) {
      final index = items.indexWhere(
        (element) => element.saleItemId == item.saleItemId,
      );
      items[index].updateQuantity(items[index].quantity + 1);
      // items[index].quantity += 1;
      notifyListeners();
      return;
    }
    items.add(item);
    notifyListeners();
  }

  SaleItem? itemOf(ReturnSaleProvider item) =>
      invoice?.items.firstWhere((element) => element.id == item.saleItemId);

  void removeReturn(int id) {
    items.removeWhere((element) => element.saleItemId == id);
    notifyListeners();
  }

  void setInvoice(SaleInvoice inv) {
    invoice = inv;
    notifyListeners();
  }

  void clear() {
    items.clear();
    invoice = null;
    notifyListeners();
  }

  void updateReturn(ReturnSaleProvider item) {
    final index = items.indexWhere(
      (element) => element.saleItemId == item.saleItemId,
    );
    if (index != -1) {
      items[index] = item;
      notifyListeners();
    }
  }

  void save() {
    notifyListeners();
  }

  double get total {
    double total = 0;
    if (invoice != null) {
      for (var r in items) {
        for (var s in invoice!.items) {
          if (s.id == r.saleItemId) {
            total += r.quantity * double.parse(s.unitPrice);
            break;
          }
        }
      }
    }
    return total;
  }
}

class ReturnSaleProvider extends ChangeNotifier {
  final int saleItemId;
  int quantity;
  // final String returnType;
  ReturnSaleProvider({
    required this.saleItemId,
    required this.quantity,
    // required this.returnType,
  });
void updateQuantity(int q) {
    quantity = q;
    notifyListeners();
  }
}
