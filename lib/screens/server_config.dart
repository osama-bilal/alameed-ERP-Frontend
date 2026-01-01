import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static const String key = 'server_base_url';
  // Fallback URL if nothing is configured
  static const String defaultUrl = 'http://127.0.0.1:8000';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(key);
    return (url != null && url.isNotEmpty) ? url : defaultUrl;
  }
}
