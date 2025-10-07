import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/services/api_client.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class SaleInvoiceController {
  final BuildContext context;
  SaleInvoiceController({required this.context});

  void createInvoice(SaleInvoice invoice) {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(
      context,
    ).add(AddItem(AppService.saleInvoiceService, invoice));
  }

  void fetchDrafts() {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(context).add(
      LoadItems<SaleInvoice>(
        GeneralService<SaleInvoice>(
          endpoint: "/invoices/sales/get_drafts/",
          fromMap: SaleInvoice.fromMap,
          toMap: (o) => o.toMap(),
        ),
      ),
    );
  }

  void finalize(int id) async {
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

  void pay(int id, String paid) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.saleInvoiceUrl}$id/mark_paid/",
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

  void cancel(int id) async {
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
    BlocProvider.of<GeneralBloc<SaleInvoice>>(
      context,
    ).add(LoadItems<SaleInvoice>(AppService.saleInvoiceService));
  }
}
