import 'package:dio/dio.dart';
import 'api_client.dart';

class GeneralService<T> {
  final ApiClient _api = ApiClient();
  String endpoint;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  GeneralService({
    required this.endpoint,
    required this.fromMap,
    required this.toMap,
  });

  Future<List<T>> fetchList({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _api.dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      final data = response.data as List;
      return data.map((json) => fromMap(json)).toList();
    } on Exception catch (e) {
      throw Exception("Failed to Fetch items: $e");
    }
  }

  Future<T> fetchItem(int? id) async {
    final point = id == null ? endpoint : "$endpoint$id/";
    try {
      final response = await _api.dio.get(point);
      final data = response.data as Map<String, dynamic>;
      return fromMap(data);
    } on DioException catch (e) {
      throw Exception("Failed to Fetch items: $e");
    }
  }

  Future<T> create(T item) async {
    try {
      final response = await _api.dio.post(endpoint, data: toMap(item));
      return fromMap(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to create item: $e");
    }
  }

  Future<T> update(int id, T item) async {
    try {
      final response = await _api.dio.put("$endpoint$id/", data: toMap(item));
      return fromMap(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to update item: $e");
    }
  }

  Future<T> patch(int id, Map<String, dynamic> fields) async {
    try {
      final response = await _api.dio.patch("$endpoint$id/", data: fields);
      return fromMap(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to patch item: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.dio.delete("$endpoint$id/");
    } on DioException catch (e) {
      throw Exception("Failed to delete item: $e");
    }
  }
}
