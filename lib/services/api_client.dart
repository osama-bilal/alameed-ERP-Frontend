// services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/services/custom_failures.dart';
import 'auth_service.dart';

class ApiClient {
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    dio.options.baseUrl = AppUrls.serverUrl;
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
            final statusCode = e.response?.statusCode;
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
            } else if (statusCode! >= 500) {
              throw ServerFailure(statusCode); // خطأ سيرفر
            } else if (statusCode >= 400) {
              // يمكنك تحليل الـ body للرسالة المخصصة
              throw ClientFailure(
                statusCode,
                e.response?.data['message']?.toString() ??
                    'خطأ في بيانات العميل',
              );
            }
            // Forward original error to caller so it can be handled without crashing the app
            // throw (e);
          } catch (err) {
            // Any unexpected error -> reject so it can be caught upstream
            handler.reject(
              DioException(requestOptions: e.requestOptions, error: err),
            );
          }
        },
      ),
    );
  }
}
