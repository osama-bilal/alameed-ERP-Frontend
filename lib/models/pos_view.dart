import 'dart:convert';

class POSView {
  final int id;
  final String name;
  final String barcode;
  final String price;
  final String cost;
  int quantity;
  final String brand;
  final String category;

  POSView({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.brand,
    required this.category,
  });

  factory POSView.fromMap(Map<String, dynamic> map) {
    return POSView(
      id: map['id'],
      name: map['view_name'],
      barcode: map['barcode'],
      price: map['price'],
      cost: map['cost'],
      quantity: map['quantity'],
      brand: map['brand'],
      category: map['category'],
    );
  }

  factory POSView.fromJson(String s) => POSView.fromMap(json.decode(s));

  @override
  String toString() {
    return "$name, $price, $barcode, $brand, $category";
  }
}
    //   {
    //     "id": 14,
    //     "view_name": "a15 - color: black, storage: 64GB",
    //     "barcode": "1010101010",
    //     "price": "1050.00",
    //     "cost": "1000.00",
    //     "quantity": 0,
    //     "brand": "samsung",
    //     "category": "phones"
    // },