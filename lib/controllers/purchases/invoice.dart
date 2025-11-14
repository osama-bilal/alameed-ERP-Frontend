import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/services/api_client.dart';

class PurchaseInvoiceController {
  final BuildContext context;
  PurchaseInvoiceController({required this.context});

  void createInvoice(PurchaseInvoice invoice) {
    BlocProvider.of<GeneralBloc<PurchaseInvoice>>(
      context,
    ).add(AddItem(invoice));
  }

  void fetchDrafts() {
    BlocProvider.of<GeneralBloc<PurchaseInvoice>>(
      context,
    ).add(LoadItems(tempPoint: "${AppUrls.purchaseInvoiceUrl}get_drafts/"));
  }

  void finalize(int id) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.purchaseInvoiceUrl}$id/finalize/",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.data['status'])));
      });
    } catch (e) {
      throw Exception("Error While finalizing the invoice,\nError: $e");
    }
  }

  void pay(int id, String paid) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.purchaseInvoiceUrl}$id/mark_paid/",
        data: {"paid": paid},
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.data['status'])));
      });
    } catch (e) {
      throw Exception("Error While mark invoice paid,\nError: $e");
    }
  }

  void setUnpaid(int id) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.purchaseInvoiceUrl}$id/mark_unpaid/",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.data['status'])));
      });
    } catch (e) {
      throw Exception("Error While mark invoice unpaid,\nError: $e");
    }
  }

  void cancel(int id) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.purchaseInvoiceUrl}$id/cancel/",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.data['status'])));
      });
    } catch (e) {
      throw Exception("Error While cancel invoice $id,\nError: $e");
    }
  }

  void fetchAll() {
    BlocProvider.of<GeneralBloc<PurchaseInvoice>>(
      context,
    ).add(LoadItems<PurchaseInvoice>());
  }

  void update(int id, PurchaseInvoice item) {
    BlocProvider.of<GeneralBloc<PurchaseInvoice>>(
      context,
    ).add(UpdateItem(item: item, itemId: id));
  }
}
