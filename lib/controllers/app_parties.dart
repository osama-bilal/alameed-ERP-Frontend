import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class PartyController {
  PartyController({required this.context});
  final BuildContext context;

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
  }
}

class Group {}

class Permission {}

class ContentType {}
