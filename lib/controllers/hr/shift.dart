import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/services/api_client.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import '../../models/shift.dart';

class ShiftController extends MainController<Shift> {
  ShiftController({required super.context, required super.service});
  void open(String balance) {
    final service = GeneralService<Shift>(
      endpoint: "${AppUrls.shiftUrl}open/",
      fromMap: Shift.fromMap,
      toMap: (o) => o.toMap(),
    );
    BlocProvider.of<GeneralBloc<Shift>>(
      context,
    ).add(AddItem<Shift>(service, Shift(openingBalance: balance)));
  }

  void close(int id, String countedCash) async {
    final api = ApiClient();
    try {
      final response = await api.dio.post(
        "${AppUrls.shiftUrl}$id/close/",
        data: {"counted_cash": countedCash},
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.data['status'])));
      });
      BlocProvider.of<GeneralBloc<Shift>>(context, listen: false).add(
        LoadSinglItem(service, itemId: id),
      ); // = ItemOperationSuccess(item: null, operation: operation)
    } on DioException catch (e) {
      throw Exception("Error While closing the Shift,\nError: $e");
    }
  }

  void getOpened() {
    final service = GeneralService<Shift>(
      endpoint: "${AppUrls.shiftUrl}get_opened/",
      fromMap: Shift.fromMap,
      toMap: (o) => o.toMap(),
    );
    BlocProvider.of<GeneralBloc<Shift>>(
      context,
    ).add(LoadSinglItem<Shift>(service));
  }
}
