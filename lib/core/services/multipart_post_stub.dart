import 'package:http/http.dart' as http;

Future<http.Response> sendMultipart({
  required Uri uri,
  required Map<String, String> headers,
  required Map<String, String> fields,
  required String fileField,
  required List<int> fileBytes,
  required String fileName,
}) {
  throw UnsupportedError('Multipart upload is not supported on this platform.');
}
