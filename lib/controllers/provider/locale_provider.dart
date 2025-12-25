import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    String? languageCode = await _storage.read(key: 'language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) {
    if (!['ar', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    _storage.write(key: 'language_code', value: locale.languageCode);
    notifyListeners();
  }
}
