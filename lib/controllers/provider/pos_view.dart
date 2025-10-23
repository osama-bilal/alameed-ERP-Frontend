import 'package:flutter/widgets.dart';
import 'package:ponit_of_sales/models/pos_view.dart';

class ProductsProvider extends ChangeNotifier {
  List<POSView> pros = [];

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
}
