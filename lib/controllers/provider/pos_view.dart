import 'package:flutter/widgets.dart';
import 'package:ponit_of_sales/models/pos_view.dart';

class ProductsProvider extends ChangeNotifier {
  List<POSView> pros = [];

  String nameOf(int id) {
    return pros.firstWhere((element) => element.id == id).name;
  }
}
