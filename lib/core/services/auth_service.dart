import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthException implements Exception {
  final String message;
  final String? type;
  AuthException(this.message, {this.type});
}

class AuthService {
  static const String _baseUrl =
      'https://ampland-kent-lit-embedded.trycloudflare.com';
  //static const String _baseUrl = 'http://192.168.1.59:8081';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Web fallback
  static final Map<String, String> _webStorage = {};

  static Future<void> _write(String key, String? value) async {
    if (value == null) return;

    if (kIsWeb) {
      _webStorage[key] = value;
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      return _webStorage[key];
    }
    return await _storage.read(key: key);
  }

  static Future<void> _deleteAll() async {
    if (kIsWeb) {
      _webStorage.clear();
    } else {
      await _storage.deleteAll();
    }
  }

  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/v1/athz10/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'userPwdEnc': password}),
        )
        .timeout(const Duration(seconds: 10));

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final resultCode = body['resultCode'];

    if (resultCode == 200) {
      final result = body['result'] as Map<String, dynamic>?;

      if (result?['dupLoginYn'] == 'Y') {
        throw AuthException(
          body['resultUserMessage']?.toString() ?? '중복 로그인',
          type: 'DUP_LOGIN',
        );
      }

      final accessToken = response.headers['authorization'];
      final refreshToken = response.headers['x-refresh-token'];

      if (accessToken == null || accessToken.isEmpty) {
        throw AuthException(
          body['resultUserMessage']?.toString() ?? '토큰을 받지 못했습니다.',
          type: 'SERVER_ERROR',
        );
      }

      await _write('access_token', accessToken);
      await _write('refresh_token', refreshToken);
      await _write('user_id', userId);

      return body;
    } else {
      final result = body['result'] as Map<String, dynamic>?;
      final message =
          body['resultUserMessage'] ?? result?['message'] ?? '로그인 실패';
      final type = result?['message']?.toString();

      throw AuthException(message.toString(), type: type);
    }
  }

  static Future<void> logout() async {
    await _deleteAll();
  }

  static Future<String?> getAccessToken() => _read('access_token');
  static Future<String?> getRefreshToken() => _read('refresh_token');
  static Future<String?> getUserId() => _read('user_id');

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
