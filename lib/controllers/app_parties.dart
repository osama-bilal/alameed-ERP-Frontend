import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class PartyController {
  PartyController({required this.context});
  final BuildContext context;

  Future<List<ViewParty<Customer>>> fethCustomers() async {
    final tempService = GeneralService<ViewParty<Customer>>(
      endpoint: "/parties/customers/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems<ViewParty<Customer>>(tempService: tempService));
  }

  Future<List<ViewParty<Supplier>>> fethSuppliers() async {
    final tempService = GeneralService<ViewParty<Supplier>>(
      endpoint: "/parties/suppliers/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems<ViewParty<Supplier>>(tempService: tempService));
  }

  Future<List<ViewParty<Employee>>> fethEmployees() async {
    final tempService = GeneralService<ViewParty<Employee>>(
      endpoint: "/parties/employees/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems<ViewParty>(tempService: tempService));
  }

  Future<List<ViewParty<Report>>> fethReports() async {
    final tempService = GeneralService<ViewParty<Report>>(
      endpoint: "/parties/reports/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems(tempService: tempService));
  }

  Future<List<ViewParty<Group>>> fethGroups() async {
    final tempService = GeneralService<ViewParty<Group>>(
      endpoint: "/parties/groups/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems(tempService: tempService));
  }

  Future<List<ViewParty<Permission>>> fethPermissions() async {
    final tempService = GeneralService<ViewParty<Permission>>(
      endpoint: "/parties/permissions/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems(tempService: tempService));
  }

  Future<List<ViewParty<ContentType>>> fethContentTypes() async {
    final tempService = GeneralService<ViewParty<ContentType>>(
      endpoint: "/parties/contenttypes/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems(tempService: tempService));
  }

  Future<List<ViewParty<T>>> fetchWithEndpoint<T>(String endpoint) async {
    final tempService = GeneralService<ViewParty<T>>(
      endpoint: "/parties/$endpoint/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
    // BlocProvider.of<GeneralBloc<ViewParty>>(
    //   context,
    // ).add(LoadItems(tempService: tempService));
  }
}

class Group {}

class Permission {}

class ContentType {}
