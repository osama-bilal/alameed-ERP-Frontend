import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class ReturnProvider extends ChangeNotifier {
  Set<ReturnSaleProvider> items = {};
  SaleInvoice? invoice;

  /// Adds an item to the return list or increments its quantity if it already exists.
  void addReturn(ReturnSaleProvider item) {
    // Find the original item from the invoice to check constraints.
    final originalSaleItem = itemOf(item);
    if (originalSaleItem == null) {
      // Don't add an item that doesn't exist in the original invoice.
      return;
    }

    try {
      // Check if the item already exists in the set.
      final existingItem = items.firstWhere(
        (element) => element.saleItemId == item.saleItemId,
      );
      // If it exists, increment its quantity.
      if (existingItem.quantity < originalSaleItem.quantity) {
        existingItem.updateQuantity(existingItem.quantity + 1);
      }
    } catch (e) {
      // If it doesn't exist, add it to the set.
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
      return null;
    }
  }

  void removeReturn(ReturnSaleProvider item) {
    if (items.remove(item)) {
      notifyListeners();
    }
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
    try {
      final existingItem = items.firstWhere(
        (element) => element.saleItemId == item.saleItemId,
      );
      // The item exists, so we update its quantity.
      // The `updateQuantity` method will call notifyListeners for the item itself.
      existingItem.updateQuantity(item.quantity);
    } catch (e) {
      // Item not found, do nothing or log an error.
    }
  }

  void save() {
    notifyListeners();
  }

  double get total {
    double total = 0;
    if (invoice != null) {
      for (var r in items) {
        final originalItem = itemOf(r);
        if (originalItem != null) {
          final price = double.tryParse(originalItem.unitPrice) ?? 0.0;
          total += r.quantity * price;
        }
      }
    }
    return total;
  }
}

class ReturnSaleProvider extends ChangeNotifier {
  final int saleItemId;
  int quantity;
  ReturnSaleProvider({required this.saleItemId, required this.quantity});

  void updateQuantity(int q) {
    quantity = q;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    return other is ReturnSaleProvider && other.saleItemId == saleItemId;
  }

  @override
  int get hashCode => saleItemId.hashCode;
}
