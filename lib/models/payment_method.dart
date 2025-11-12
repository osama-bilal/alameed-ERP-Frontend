import 'dart:convert';

class PaymentMethod {
  int? id;
  String methodName;
  bool isActive;

  PaymentMethod({this.id, required this.methodName, this.isActive = true});

  Map<String, dynamic> toMap() {
    return {'id': id, 'method_name': methodName, 'is_active': isActive ? 1 : 0};
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      methodName: map['method_name'],
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
  }

  String toJson() => json.encode(toMap());
  factory PaymentMethod.fromJson(String s) =>
      PaymentMethod.fromMap(json.decode(s));

  static List<String> get columnsName => ['ID', 'Method Name', 'Is Active'];
  @override
  String toString() => methodName;

  @override
  bool operator ==(Object other) {
    return other is PaymentMethod && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
