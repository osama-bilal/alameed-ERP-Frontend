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
  }

  List<ViewParty<T>> get<T>() {
    try {
      return parties.whereType<ViewParty<T>>().toList();
    } on Exception catch (_) {
      return [];
    }
  }

  Future<void> getReady() async {
    final tempService = GeneralService<ViewParty>(
      endpoint: "",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      tempService.endpoint = "/parties/customers/";
      final items = await tempService.fetchList();
 addList<Customer>(items.cast<ViewParty<Customer>>());
    } on Exception catch (_) {}

    try {
      tempService.endpoint = "/parties/suppliers/";
      final items = await tempService.fetchList();
      addList<Supplier>(items as List<ViewParty<Supplier>>);
    } on Exception catch (_) {}

    try {
      tempService.endpoint = "/parties/employees/";
      final items = await tempService.fetchList();
      addList<Employee>(items as List<ViewParty<Employee>>);
    } on Exception catch (_) {}

    try {
      tempService.endpoint = "/parties/groups/";
      final items = await tempService.fetchList();
      addList<Group>(items as List<ViewParty<Group>>);
    } on Exception catch (_) {}

    try {
      tempService.endpoint = "/parties/permissions/";
      final items = await tempService.fetchList();
      addList<Permission>(items as List<ViewParty<Permission>>);
    } on Exception catch (_) {}

    try {
      tempService.endpoint = "/parties/contenttypes/";
      final items = await tempService.fetchList();
      addList<ContentType>(items as List<ViewParty<ContentType>>);
    } on Exception catch (_) {}
  }
}
