import 'api_client.dart';

class GeneralService<T> {
  final ApiClient _api = ApiClient();
  String endpoint;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  GeneralService({required this.endpoint, required this.fromMap, required this.toMap});

  Future<List<T>> fetchList() async {
    final response = await _api.dio.get(endpoint);
    final data = response.data as List;
    return data.map((json) => fromMap(json)).toList();
  }

  Future<T> fetchItem(int id) async {
    try {
      final response = await _api.dio.get(
        "$endpoint$id/",
      );
      final data = response.data as Map<String, dynamic>;
      return fromMap(data);
    } catch (e) {
      throw Exception("Failed to Fetch items: $e");
    }
  }

  Future<T> create(T item) async {
    try {
      final response = await _api.dio.post(
        endpoint,
        data: toMap(item),
      );
      return fromMap(response.data);
    } catch (e) {
      throw Exception("Failed to create item: $e");
    }
  }

 Future<T> update(int id, T item) async {
    try {
      final response = await _api.dio.put(
        "$endpoint$id/",
        data: toMap(item),
      );
      return fromMap(response.data);
    } catch (e) {
      throw Exception("Failed to update item: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.dio.delete("$endpoint$id/");
    } catch (e) {
      throw Exception("Failed to delete item: $e");
    }
  }
}
