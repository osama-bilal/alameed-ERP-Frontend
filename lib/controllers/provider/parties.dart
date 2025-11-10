import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class AppParties extends ChangeNotifier {
  Set<ViewParty> parties = {};
  Set<ViewParty<Customer>> customers = {};
  Set<ViewParty<Supplier>> suppliers = {};
  Set<ViewParty<Employee>> employees = {};
  Set<ViewParty<Group>> groups = {};
  Set<ViewParty<Permission>> permissions = {};
  Set<ViewParty<ContentType>> contentTypes = {};
  final tempService = GeneralService<ViewParty<Object>>(
    endpoint: "",
    fromMap: ViewParty<Object>.fromMap,
    toMap: (o) => o.toMap(),
  );

  void save() {
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    customers.clear();
    customers.addAll(await load<Customer>("customers"));
    save();
  }

  Future<void> fetchSuppliers() async {
    suppliers.clear();
    suppliers.addAll(await load<Supplier>("suppliers"));
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

  Future<void> fetchCT() async {
    contentTypes.clear();
    contentTypes.addAll(await load<ContentType>("contenttypes"));
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

  Future<void> getReady() async {
    customers.clear();
    customers.addAll(await load<Customer>("customers"));

    suppliers.clear();
    suppliers.addAll(await load<Supplier>("suppliers"));

    employees.clear();
    employees.addAll(await load<Employee>("employees"));

    groups.clear();
    groups.addAll(await load<Group>("groups"));

    permissions.clear();
    permissions.addAll(await load<Permission>("permissions"));

    contentTypes.clear();
    contentTypes.addAll(await load<ContentType>("contenttypes"));
    save();
  }
}
