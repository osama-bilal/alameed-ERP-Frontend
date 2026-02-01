import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/controllers/provider/shift.dart';
import '/core/main.dart';
import '/services/api_client.dart';
import 'package:provider/provider.dart';
import '../../models/shift.dart';

class ShiftController extends MainController<Shift> {
  ShiftController({required super.context, super.tempEndPoint});
  void open(String balance) {
    BlocProvider.of<GeneralBloc<Shift>>(context).add(
      AddItem(
        Shift(openingBalance: balance),
        tempPoint: "${AppUrls.shiftUrl}open/",
      ),
    );
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
    BlocProvider.of<GeneralBloc<Shift>>(
      context,
    ).add(LoadSinglItem(tempPoint: "${AppUrls.shiftUrl}get_opened/"));
  }
}
