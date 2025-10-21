import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/services/api_client.dart';
import '../../core/main.dart';
part 'internet_connect_state.dart';

class InternetConnectCubit extends Cubit<InternetConnectState> {
  InternetConnectCubit() : super(InternetConnectInitial());
  final _apiClient = ApiClient();
  Future<void> checkConnection() async {
    try {
      final response = await _apiClient.dio.fetch(
        RequestOptions(baseUrl: AppUrls.serverUrl, path: AppUrls.productUrl),
      );
      if (200 <= response.statusCode! && 300 >= response.statusCode!) {
        emit(ConnectedState(message: "Connected to server successfully"));
      }
    } catch (e) {
      emit(FieldState(message: "Filed to connect to the server"));
    }
  }
}
