// services/auth_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:ponit_of_sales/services/custom_failures.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final ApiClient _api = ApiClient();
  static const _keyAccessToken = "access_token";
  static const _keyRefreshToken = "refresh_token";
  static const _keyUser = "auth_user";

  Future<User> login(String username, String password) async {
    try {
      final response = await _api.dio.post(
        "/users/api/login/",
        data: {"username": username, "password": password},
      );

      if (response.statusCode == 200) {
        final access = response.data["access"];
        final refresh = response.data["refresh"];
        final userData = response.data["user"];
        final user = User.fromMap(userData);

        await _storage.write(key: _keyAccessToken, value: access);
        await _storage.write(key: _keyRefreshToken, value: refresh);
        await _storage.write(key: _keyUser, value: user.toJson());

        return user;
      }
      debugPrint(response.data.toString());
      throw ClientFailure(
        response.statusCode!,
        "Login failed ${response.statusMessage}",
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["detail"] ?? "Login failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<User?> getStoredUser() async {
    final userJson = await _storage.read(key: _keyUser);
    if (userJson != null) {
      return User.fromMap(jsonDecode(userJson));
    }
    return null;
  }

  /// Verifies if the current access token is valid.
  Future<bool> verifyToken() async {
    final token = await getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      // We expect a 200 OK response if the token is valid.
      // A 401 Unauthorized will be thrown if it's invalid, which is handled by the catch block.
      await _api.dio.post(
        "/api/token/verify/",
        data: {"token": token},
        options: Options(extra: {'is_retry': true}),
      );
      return true;
    } on DioException {
      // Any DioException (like 401) means the token is not valid.
      return false;
    }
  }

  /// Refresh access token
  Future<String?> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return null;
    try {
      final response = await _api.dio.post(
        "/api/token/refresh/",
        data: {"refresh": refresh},
        options: Options(extra: {'is_retry': true}),
      );
      final newAccess = response.data["access"];
      await _storage.write(key: _keyAccessToken, value: newAccess);
      return newAccess;
    } on DioException catch (_) {
      await logout();
      return null;
    }
  }
}
