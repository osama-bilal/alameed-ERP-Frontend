// services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class ApiClient {
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    dio.options.baseUrl = "http://127.0.0.1:8000";
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: "access_token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          try {
            if (e.response?.statusCode == 401) {
              final authService = AuthService();
              final newToken = await authService.refreshToken();
              if (newToken != null) {
                // retry request with new token
                final retryReq = e.requestOptions;
                retryReq.headers["Authorization"] = "Bearer $newToken";

                try {
                  final response = await dio.fetch(retryReq);
                  return handler.resolve(response);
                } catch (err) {
                  if (err is DioException) {
                    return handler.reject(err);
                  }
                  return handler.reject(
                    DioException(requestOptions: e.requestOptions, error: err),
                  );
                }
              }
            }
            // Forward original error to caller so it can be handled without crashing the app
            throw (e);
          } catch (err) {
            // Any unexpected error -> reject so it can be caught upstream
            return handler.reject(
              DioException(requestOptions: e.requestOptions, error: err),
            );
          }
        },
      ),
    );
  }
}
