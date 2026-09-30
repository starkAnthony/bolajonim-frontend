import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/api_error_utils.dart';
import 'auth_service.dart';
import 'multipart_post.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );

    final response = await http
        .get(uri, headers: await _headers(authenticated: authenticated))
        .timeout(const Duration(seconds: 15));

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final response = await http
        .post(
          uri,
          headers: await _headers(authenticated: authenticated),
          body: body == null ? null : utf8.encode(jsonEncode(body)),
        )
        .timeout(const Duration(seconds: 15));

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final response = await http
        .put(
          uri,
          headers: await _headers(authenticated: authenticated),
          body: body == null ? null : utf8.encode(jsonEncode(body)),
        )
        .timeout(const Duration(seconds: 15));

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );

    final response = await http
        .delete(uri, headers: await _headers(authenticated: authenticated))
        .timeout(const Duration(seconds: 15));

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await sendMultipart(
      uri: uri,
      headers: await AuthService.authHeaders(),
      fields: fields,
      fileField: fileField,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return _decodeResponse(response);
  }

  static Future<Map<String, String>> _headers({
    required bool authenticated,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
    };

    if (authenticated) {
      headers.addAll(await AuthService.authHeaders());
    }

    return headers;
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.bodyBytes.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final resultCode = body['resultCode'];
    final isSuccess = response.statusCode >= 200 &&
        response.statusCode < 300 &&
        (resultCode == null || resultCode == 200);

    if (!isSuccess) {
      throw ApiException(
        ApiErrorUtils.fromResponseBody(body),
        statusCode: response.statusCode,
      );
    }

    return body;
  }

  static T resultData<T>(Map<String, dynamic> body) {
    return body['result'] as T;
  }
}
