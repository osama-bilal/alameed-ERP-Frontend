import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:provider/provider.dart';

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
      context.read<AppParties>().removeList<Customer>();
      context.read<AppParties>().addList<Customer>(items);
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<Supplier>>> fethSuppliers() async {
    final tempService = GeneralService<ViewParty<Supplier>>(
      endpoint: "/parties/suppliers/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<Supplier>();
      context.read<AppParties>().addList<Supplier>(items);
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<Employee>>> fethEmployees() async {
    final tempService = GeneralService<ViewParty<Employee>>(
      endpoint: "/parties/employees/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<Employee>();
      context.read<AppParties>().addList<Employee>(items);

      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<Report>>> fethReports() async {
    final tempService = GeneralService<ViewParty<Report>>(
      endpoint: "/parties/reports/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<Report>();
      context.read<AppParties>().addList<Report>(items);
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<Group>>> fethGroups() async {
    final tempService = GeneralService<ViewParty<Group>>(
      endpoint: "/parties/groups/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<Group>();
      context.read<AppParties>().addList<Group>(items);
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<Permission>>> fethPermissions() async {
    final tempService = GeneralService<ViewParty<Permission>>(
      endpoint: "/parties/permissions/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<Permission>();
      context.read<AppParties>().addList<Permission>(items);
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<ContentType>>> fethContentTypes() async {
    final tempService = GeneralService<ViewParty<ContentType>>(
      endpoint: "/parties/contenttypes/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<ContentType>();
      context.read<AppParties>().addList<ContentType>(items);
      return items;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
    return [];
  }

  Future<List<ViewParty<T>>> fetchWithEndpoint<T>(String endpoint) async {
    final tempService = GeneralService<ViewParty<T>>(
      endpoint: "/parties/$endpoint/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    );
    try {
      final items = await tempService.fetchList();
      context.read<AppParties>().removeList<T>();
      context.read<AppParties>().addList<T>(items);
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
