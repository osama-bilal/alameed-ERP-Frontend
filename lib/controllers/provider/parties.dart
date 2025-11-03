import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class AppParties extends ChangeNotifier {
  Set<ViewParty> parties = {};

  void addList<T>(List<ViewParty<T>> l) {
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
  Future<void> getReady() async {
    Future<void> load<T>(String path) async {
  final tempService = GeneralService<ViewParty>(
    endpoint: "",
    fromMap: ViewParty.fromMap,
    toMap: (o) => o.toMap(),
  );
      tempService.endpoint = path;
      final raw = await tempService.fetchList();
      final typed = raw.map((e) {
        // نفترض أن ViewParty.fromMap يعرف يبني ViewParty<T>
        return ViewParty<T>.fromMap(e.toMap());
      }).toList();
      addList<T>(typed);
    }

    try {
      await load<Customer>("/parties/customers/");
    } catch (_) {}
    try {
      await load<Supplier>("/parties/suppliers/");
    } catch (_) {}
    try {
      await load<Employee>("/parties/employees/");
    } catch (_) {}
    try {
      await load<Group>("/parties/groups/");
    } catch (_) {}
    try {
      await load<Permission>("/parties/permissions/");
    } catch (_) {}
    try {
      await load<ContentType>("/parties/contenttypes/");
    } catch (_) {}
  }
}
