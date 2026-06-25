import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

class AuthException implements Exception {
  final String message;
  final String? type;
  AuthException(this.message, {this.type});
}

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
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

  static String _normalizeStoredToken(String? token) {
    if (token == null || token.isEmpty) return '';
    return token.startsWith('Bearer ') ? token.substring(7) : token;
  }

  static String _authorizationHeader(String? token) {
    final normalized = _normalizeStoredToken(token);
    if (normalized.isEmpty) return '';
    return 'Bearer $normalized';
  }

  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginPath}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'userPwdEnc': password}),
        )
        .timeout(const Duration(seconds: 10));

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final resultCode = body['resultCode'];
    final result = body['result'] as Map<String, dynamic>?;

    final errorCode = result?['errorCode']?.toString();
    if (errorCode != null && errorCode.isNotEmpty) {
      throw AuthException(
        _loginErrorMessage(errorCode),
        type: errorCode,
      );
    }

    if (resultCode == 200) {

      if (result?['dupLoginYn'] == 'Y') {
        throw AuthException(
          body['resultUserMessage']?.toString() ?? 'Duplicate login',
          type: 'DUP_LOGIN',
        );
      }

      final accessToken = _normalizeStoredToken(response.headers['authorization']);
      final refreshToken = _normalizeStoredToken(
        response.headers['x-refresh-token'],
      );

      if (accessToken.isEmpty) {
        throw AuthException(
          body['resultUserMessage']?.toString() ?? 'Token not received',
          type: 'SERVER_ERROR',
        );
      }

      if (refreshToken.isEmpty) {
        throw AuthException(
          'Refresh token not received',
          type: 'SERVER_ERROR',
        );
      }

      await _write('access_token', accessToken);
      await _write('refresh_token', refreshToken);
      await _write('user_id', userId);
      await _write('user_nm', result?['userNm']?.toString());
      await saveUserRole(_normalizeRole(result?['rofcCd']?.toString()));

      return body;
    } else {
      final message = _loginErrorMessage(
        errorCode ?? result?['message']?.toString(),
      );

      throw AuthException(message, type: errorCode ?? result?['message']?.toString());
    }
  }

  static String _loginErrorMessage(String? codeOrMessage) {
    const messages = {
      'INVALID_USER_INFO': 'Telefon, ID, email yoki parol noto\'g\'ri.',
      'INVALID_ID_PASSWORD': 'Telefon, ID, email yoki parol noto\'g\'ri.',
      'INVALID_PASSWORD': 'Telefon, ID, email yoki parol noto\'g\'ri.',
      'OVER_FAIL_COUNT':
          'Kirish urinishlari soni oshib ketdi. Administratorga murojaat qiling.',
      'LONG_TERM_NO_LOGIN_USER': 'Uzoq vaqt kirish amalga oshirilmagan.',
      'USER_RESIGNED': 'Bu hisob faol emas.',
      'PWD_CHANGE_NECESSITY': 'Parolni yangilash zarur.',
      'PWD_INIT_STATE': 'Parolingiz tiklangan. Yangi parol o\'rnating.',
      'LOCKED_USER': 'Hisob bloklangan. Administratorga murojaat qiling.',
    };

    if (codeOrMessage != null && messages.containsKey(codeOrMessage)) {
      return messages[codeOrMessage]!;
    }

    if (codeOrMessage != null &&
        !_looksLikeKorean(codeOrMessage) &&
        codeOrMessage.isNotEmpty) {
      return codeOrMessage;
    }

    return 'Telefon, ID, email yoki parol noto\'g\'ri.';
  }

  static bool _looksLikeKorean(String message) {
    return message.contains('잘못된') ||
        message.contains('로그인') ||
        message.contains('계정') ||
        message.contains('서버 오류');
  }

  static String _normalizeRole(String? rofcCd) {
    final normalized = (rofcCd ?? 'PARENT').toUpperCase();
    if (normalized.contains('TEACHER')) return 'teacher';
    if (normalized.contains('DIRECTOR') || normalized.contains('ADMIN')) {
      return 'director';
    }
    return 'parent';
  }

  static Future<void> logout() async {
    await _deleteAll();
  }

  static Future<String?> getAccessToken() => _read('access_token');
  static Future<String?> getRefreshToken() => _read('refresh_token');
  static Future<String?> getUserId() => _read('user_id');
  static Future<String?> getUserName() => _read('user_nm');

  static Future<void> saveUserRole(String role) => _write('user_role', role);

  static Future<String?> getUserRole() => _read('user_role');

  static Future<void> saveSelectedChildNo(String? childNo) async {
    if (childNo == null || childNo.isEmpty) {
      if (kIsWeb) {
        _webStorage.remove('selected_child_no');
      } else {
        await _storage.delete(key: 'selected_child_no');
      }
      return;
    }

    await _write('selected_child_no', childNo);
  }

  static Future<String?> getSelectedChildNo() => _read('selected_child_no');

  static Future<Map<String, String>> authHeaders() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    final headers = <String, String>{};
    final authorization = _authorizationHeader(accessToken);
    final refresh = _authorizationHeader(refreshToken);

    if (authorization.isNotEmpty) {
      headers['Authorization'] = authorization;
    }
    if (refresh.isNotEmpty) {
      headers['X-Refresh-Token'] = refresh;
    }

    return headers;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
