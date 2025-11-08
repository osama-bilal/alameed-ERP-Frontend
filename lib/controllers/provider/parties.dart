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
void save(){
notifyListeners();
}
  /* void addList<T>(List<ViewParty<T>> l) {
    parties.addAll(l);
    notifyListeners();
  }

  void add<T>(ViewParty<T> p) {
    parties.add(p);
    notifyListeners();
  }

  void remove<T>(ViewParty<T> p) {
    parties.remove(p);
    notifyListeners();
  }

  void update<T>(ViewParty<T> p) {
    parties.remove(p);
    parties.add(p);
    notifyListeners();
  }

  void removeList<T>() {
    parties.removeWhere((element) => element.type == T);
    notifyListeners();
  }

  List<ViewParty> get<T>() {
    return parties.where((p) => p.type == T).toList();
  }
*/
Future<void> fetchCustomers() async {
customers.clear();
customers.addAll(await load<Customer>("/parties/customers/"));
notifyListeners();
}
Future<void> fetchSuppliers() async {
suppliers.clear();
suppliers.addAll(await load<Supplier>("/parties/suppliers/"));
notifyListeners();
}
Future<void> fetchEmployees() async {
employees.clear();
employees.addAll(await load<Employee>("/parties/employees/"));
notifyListeners();
}
Future<void> fetchGroups() async {
groups.clear{};
groups.addAll(await load<Group>("/parties/groups/"));
notifyListeners();
}
Future<void> fetchPermissions() async {
permissions.clear();
permissions.addAll(await load<Permission>("/parties/permissions/"));
notifyListeners();
}
Future<void> fetchCT() async {
contentTypes.clear();
contentTypes.addAll(await load<ContentType>("/parties/contenttypes/"));
notifyListeners();
}


Future<List<ViewParty<T>>> load<T>(String path) async {
       
      this.tempService.endpoint = "/parties/$path/";
      final raw = await tempService.fetchList();
      final typed = raw.map((e) {
        // نفترض أن ViewParty.fromMap يعرف يبني ViewParty<T>
return ViewParty<T>(id: e.id, name: e.name);
      //  return ViewParty<T>.fromMap(e.toMap());
      }).toList();
return typed;
  //    addList<T>(typed);
    }

  Future<void> getReady() async {
    

    try {
     customers.clear();
customers.addAll(await load<Customer>("customers"));
    } catch (_) {}
    try {
     suppliers.clear();
suppliers.addAll(await load<Supplier>("suppliers"));
    } catch (_) {}
    try {
      employees.clear();
employees.addAll(await load<Employee>("employees"));
    } catch (_) {}
    try {
      groups.clear{};
groups.addAll(await load<Group>("groups"));
    } catch (_) {}
    try {
      permissions.clear();
permissions.addAll(await load<Permission>("permissions"));
    } catch (_) {}
    try {
      contentTypes.clear();
contentTypes.addAll(await load<ContentType>("contenttypes"));
    } catch (_) {}
  }
}
