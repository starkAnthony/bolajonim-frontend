import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const _languageKey = 'app_language';
  static const _notificationsKey = 'notifications_enabled';
  static const _privacyKey = 'privacy_mode_enabled';

  static Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'uz';
  }

  static Future<void> setLanguageCode(String code) async {
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
