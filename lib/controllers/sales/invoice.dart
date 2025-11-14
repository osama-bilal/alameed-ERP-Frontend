import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/services/api_client.dart';

class SaleInvoiceController {
  final BuildContext context;
  SaleInvoiceController({required this.context});

  void createInvoice(SaleInvoice invoice) {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(context).add(AddItem(invoice));
  }

  void showLoading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
    });
  }

  void fetchDrafts() {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(
      context,
    ).add(LoadItems(tempPoint: "/invoices/sales/get_drafts/"));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(
      context,
    ).add(PartialUpdateItem(changes: changes, itemId: id));
  }

  Future<void> finalize(int id) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.saleInvoiceUrl}$id/finalize/",
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

  Future<void> pay(int id, String paid) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.saleInvoiceUrl}$id/mark_paid/",
        data: <String, dynamic>{"paid": paid},
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

  Future<void> setUnpaid(int id) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.saleInvoiceUrl}$id/mark_unpaid/",
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

  Future<void> cancel(int id) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.saleInvoiceUrl}$id/cancel/",
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
    BlocProvider.of<GeneralBloc<SaleInvoice>>(context).add(LoadItems());
  }

  void update(int id, SaleInvoice item) {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(
      context,
    ).add(UpdateItem(item: item, itemId: id));
  }
}
