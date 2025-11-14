import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/models/brand.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class AppParties extends ChangeNotifier {
  // Set<ViewParty> parties = {};
  Set<ViewParty<Customer>> customers = {};
  Set<ViewParty<Supplier>> suppliers = {};
  Set<ViewParty<Employee>> employees = {};
  Set<ViewParty<Group>> groups = {};
  Set<ViewParty<Permission>> permissions = {};
  Set<ViewParty<ContentType>> contentTypes = {};
  Set<ViewParty<Report>> reports = {};
  Set<ViewParty<User>> users = {};
  Set<ViewParty<PaymentMethod>> payMethods = {};
  Set<ViewParty<ProductCategory>> categories = {};
  Set<ViewParty<Brand>> brands = {};
  final tempService = GeneralService<ViewParty<Object>>(
    endpoint: "",
    fromMap: ViewParty<Object>.fromMap,
    toMap: (o) => o.toMap(),
  );

  Future<void> fetchCT() async {
    contentTypes.clear();
    contentTypes.addAll(await load<ContentType>("contenttypes"));
    save();
  }

  Future<void> fetchCustomers() async {
    customers.clear();
    customers.addAll(await load<Customer>("customers"));
    save();
  }

  Future<void> fetchEmployees() async {
    employees.clear();
    employees.addAll(await load<Employee>("employees"));
    save();
  }

  Future<void> fetchGroups() async {
    groups.clear();
    groups.addAll(await load<Group>("groups"));
    save();
  }

  Future<void> fetchPermissions() async {
    permissions.clear();
    permissions.addAll(await load<Permission>("permissions"));
    save();
  }

  Future<void> fetchReports() async {
    reports.clear();
    reports.addAll(await load<Report>('reports'));
    save();
  }

  Future<void> fetchSuppliers() async {
    suppliers.clear();
    suppliers.addAll(await load<Supplier>("suppliers"));
    save();
  }

  Future<void> fetchUsers() async {
    users.clear();
    users.addAll(await load<User>("users"));
    save();
  }

  Future<void> fetchPayM() async {
    payMethods.clear();
    payMethods.addAll(await load<PaymentMethod>("payment-methods"));
    save();
  }

  Future<void> fetchCates() async {
    categories.clear();
    categories.addAll(await load<ProductCategory>("categories"));
    save();
  }

  Future<void> fetchBrands() async {
    brands.clear();
    brands.addAll(await load<Brand>("brands"));
    save();
  }

  Future<void> getReady() async {
    customers.clear();
    customers.addAll(await load<Customer>("customers"));

    suppliers.clear();
    suppliers.addAll(await load<Supplier>("suppliers"));

    employees.clear();
    employees.addAll(await load<Employee>("employees"));

    groups.clear();
    groups.addAll(await load<Group>("groups"));

    reports.clear();
    reports.addAll(await load<Report>("reports"));

    permissions.clear();
    permissions.addAll(await load<Permission>("permissions"));

    contentTypes.clear();
    contentTypes.addAll(await load<ContentType>("contenttypes"));

    users.clear();
    users.addAll(await load<User>("users"));

    payMethods.clear();
    payMethods.addAll(await load<PaymentMethod>("payment-methods"));

    brands.clear();
    brands.addAll(await load<Brand>("brands"));

    categories.clear();
    categories.addAll(await load<ProductCategory>("categories"));
    
    save();
  }

  Future<List<ViewParty<T>>> load<T>(String path) async {
    tempService.endpoint = "/parties/$path/";
    try {
      final raw = await tempService.fetchList();
      final typed = raw.map((e) {
        return ViewParty<T>(id: e.id, name: e.name);
      }).toList();
      return typed;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  void save() {
    notifyListeners();
  }
}
