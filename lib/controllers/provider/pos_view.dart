import 'package:flutter/widgets.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/pos_view.dart';

/// Enum to define the sort order.
enum SortOrder { asc, desc }

class ProductsProvider extends ChangeNotifier {
  List<POSView> pros = [];
  String? _sortColumn;
  SortOrder _sortOrder = SortOrder.asc;

  String? get sortColumn => _sortColumn;
  SortOrder get sortOrder => _sortOrder;

  List<POSView> filteredProducts(String selectedCategory) {
    if (selectedCategory == 'All' || selectedCategory == 'الكل') {
      return pros;
    } else {
      return pros
          .where((product) => product.category == selectedCategory)
          .toList();
    }
  }
  List<POSView> filteredbrand(String selectedbrand) {
    if (selectedbrand == 'All') {
      return pros;
    } else {
      return pros
          .where((product) => product.brand == selectedbrand)
          .toList();
    }
  }

  String nameOf(int id) {
    return pros
        .firstWhere(
          (element) => element.id == id,
          orElse: () => POSView(
            id: id,
            name: "Unknown",
            barcode: "Unknown",
            price: "0.0",
            cost: "0.0",
            quantity: 0,
            brand: "",
            category: "",
          ),
        )
        .name;
  }

  void checkList() {
    if (pros.isEmpty) {
      getFromServer();
    }
  }

  /// Sorts the list of products by the given field.
  /// Toggles the sort order if the same field is sorted again.
  void sortBy(String field) {
    if (_sortColumn == field) {
      // If the same column is tapped, reverse the sort order
      _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    } else {
      // If a new column is tapped, set it as the sort column and default to ascending
      _sortColumn = field;
      _sortOrder = SortOrder.asc;
    }

    pros.sort((a, b) {
      dynamic valA;
      dynamic valB;

      switch (field) {
        case 'name':
          valA = a.name.toLowerCase();
          valB = b.name.toLowerCase();
          break;
        case 'price':
          valA = double.tryParse(a.price) ?? 0.0;
          valB = double.tryParse(b.price) ?? 0.0;
          break;
        case 'quantity':
          valA = a.quantity;
          valB = b.quantity;
          break;
        case 'category':
          valA = a.category;
          valB = b.category;
          break;
        case 'brand':
          valA = a.brand;
          valB = b.brand;
          break;
        default: // Default to sorting by ID
          valA = a.id;
          valB = b.id;
      }
      final comparison = (valA as Comparable).compareTo(valB);
      return _sortOrder == SortOrder.asc ? comparison : -comparison;
    });
    notifyListeners();
  }

  void getFromServer() async {
    pros = await AppService.posViewService.fetchList();
    notifyListeners();
  }
}
