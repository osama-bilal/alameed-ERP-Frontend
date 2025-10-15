import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/shift.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/services/api_client.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:provider/provider.dart';
import '../../models/shift.dart';

class ShiftController extends MainController<Shift> {
  ShiftController({required super.context, super.tempService});
  void open(String balance) {
    final service = GeneralService<Shift>(
      endpoint: "${AppUrls.shiftUrl}open/",
      fromMap: Shift.fromMap,
      toMap: (o) => o.toMap(),
    );
    BlocProvider.of<GeneralBloc<Shift>>(
      context,
    ).add(AddItem(Shift(openingBalance: balance), tempService: service));
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
      Provider.of<ShiftProvider>(context, listen: false).close();
      });
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
    ).add(LoadSinglItem(tempService: service));
  }
}
