import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const _languageKey = 'app_language';
  static const _notificationsKey = 'notifications_enabled';
  static const _privacyKey = 'privacy_mode_enabled';

  /// In-memory copy so API errors can be translated without another prefs read.
  static String currentLanguageCode = 'uz';

  static Future<void> load() async {
    currentLanguageCode = await getLanguageCode();
  }

  static Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageKey) ?? 'uz';
    currentLanguageCode = code;
    return code;
  }

  static Future<void> setLanguageCode(String code) async {
    currentLanguageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  static Future<bool> getPrivacyModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyKey) ?? false;
  }

  static Future<void> setPrivacyModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyKey, value);
  }
}
