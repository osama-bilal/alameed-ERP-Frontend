import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/services/api_client.dart';
import '../../core/main.dart';
part 'internet_connect_state.dart';

class InternetConnectCubit extends Cubit<InternetConnectState> {
  InternetConnectCubit() : super(InternetConnectInitial()) {
    Timer.periodic(Duration(seconds: 10), (_) async {
      try {
        await _apiClient.dio.head(
          '/api/health/',
          options: Options(
            sendTimeout: Duration(milliseconds: 2000),
            receiveTimeout: Duration(seconds: 2),
          ),
        );
        if (state is FieldState) {
          emit(ConnectedState(message: "Connected to server"));
        }
      } catch (_) {
        emit(FieldState(message: "Failed to connect to the server"));
      }
    });
  }
  final _apiClient = ApiClient();
  Future<void> checkConnection() async {
    try {
      await _apiClient.dio.fetch(RequestOptions(baseUrl: AppUrls.serverUrl));
      if (state is FieldState) {
        emit(ConnectedState(message: "Connected to server successfully"));
      }
      // if (200 <= response.statusCode! && 300 >= response.statusCode!) {
      // }
    } catch (e) {
      emit(FieldState(message: "Filed to connect to the server"));
    }
  }
}
