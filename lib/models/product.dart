// product and its variants models are here

import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class Product extends BaseModel {
  int? id;
  int? brandId;
  int? categoryId;
  String name;
  String? description;
  bool isActive;

  Product({
    this.id,
    this.brandId,
    this.categoryId,
    required this.name,
    this.description,
    this.isActive = true,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'brand': brandId,
    'category': categoryId,
    'name': name,
    'description': description,
    'is_active': isActive ? 1 : 0,
  };

  factory Product.fromMap(Map<String, dynamic> map) {
    final p = Product(
      id: map['id'],
      brandId: map['brand'],
      categoryId: map['category'],
      name: map['name'],
      description: map['description'],
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
    p.baseFromMap(map);
    return p;
  }

  String toJson() => json.encode(toMap());
  factory Product.fromJson(String s) => Product.fromMap(json.decode(s));

  static List<String> get culomnsName => [
    "ID",
    "Brand ID",
    "Category ID",
    "Name",
    "Description",
    "Is Active"
  ];

  @override
  String toString() => "$brandId, $name, $description, Category: $categoryId";
}

class ProductVariant extends BaseModel {
  int? id;
  int productId;
  List<int>? optionValueIds; // ManyToMany -> store list of IDs
  String cost; // decimal string
  String price; // decimal string
  String barcode;
  int quantity;

  ProductVariant({
    this.id,
    required this.productId,
    this.optionValueIds,
    required this.cost,
    required this.price,
    required this.barcode,
    required this.quantity,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'product': productId,
    'option_values': optionValueIds,
    'cost': cost,
    'price': price,
    'barcode': barcode,
    'quantity': quantity,
  };

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    final pv = ProductVariant(
      id: map['id'],
      productId: map['product'],
      optionValueIds: (map['option_values'] is List)
          ? List<int>.from(map['option_values'])
          : (map['option_values'] == null
                ? null
                : List<int>.from(json.decode(map['option_values']))),
      cost: map['cost']?.toString() ?? '0.00',
      price: map['price']?.toString() ?? '0.00',
      barcode: map['barcode'],
      quantity: map['quantity'] ?? 0,
    );
    pv.baseFromMap(map);
    return pv;
  }

  String toJson() => json.encode(toMap());
  factory ProductVariant.fromJson(String s) =>
      ProductVariant.fromMap(json.decode(s));

  static List<String> get culomnsName => [
    "ID",
    "Product",
    "Option Value",
    "Cost",
    "Price",
    "Barcode",
    "Quantity"
  ];

  @override
  String toString() => "Barcode: $barcode, ID: $id, Cost: $cost, Price: $price, Qty: $quantity";
}
