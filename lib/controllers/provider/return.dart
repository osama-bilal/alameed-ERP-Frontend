import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class ReturnProvider extends ChangeNotifier {
  List<ReturnSaleProvider> items = [];
  SaleInvoice? invoice;

  /// Adds an item to the return list or increments its quantity if it already exists.
  void addReturn(ReturnSaleProvider item) {
    // Find the original item from the invoice to check constraints.
    final originalSaleItem = itemOf(item);
    if (originalSaleItem == null) {
      // Don't add an item that doesn't exist in the original invoice.
      return;
    }

    // final maxReturnableQuantity =
    //     originalSaleItem.quantity - originalSaleItem.returnedQuantity;

    final existingItemIndex = items.indexWhere(
      (element) => element.saleItemId == item.saleItemId,
    );

    if (existingItemIndex != -1) {
      // If item already in the return list, just increment its quantity.
      final existingReturnItem = items[existingItemIndex];
      if (existingReturnItem.quantity <= originalSaleItem.quantity) {
        existingReturnItem.updateQuantity(existingReturnItem.quantity + 1);
      }
      // No need to call notifyListeners() here as updateQuantity does it.
    } else {
      // If it's a new item, add it to the list, ensuring its quantity is valid.
      if (item.quantity <= originalSaleItem.quantity) {
        items.add(item);
        notifyListeners();
      }
    }
  }

  SaleItem? itemOf(ReturnSaleProvider item) {
    try {
      return invoice?.items.firstWhere(
        (element) => element.id == item.saleItemId,
      );
    } catch (e) {
      // Return null if the item is not found in the invoice.
      return null;
    }
  }

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
  ReturnSaleProvider({
    required this.saleItemId,
    required this.quantity,
  });
  void updateQuantity(int q) {
    quantity = q;
    notifyListeners();
  }
}
