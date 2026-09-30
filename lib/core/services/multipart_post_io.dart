import 'package:http/http.dart' as http;

Future<http.Response> sendMultipart({
  required Uri uri,
  required Map<String, String> headers,
  required Map<String, String> fields,
  required String fileField,
  required List<int> fileBytes,
  required String fileName,
}) async {
  final request = http.MultipartRequest('POST', uri);
  request.headers.addAll(headers);
  request.fields.addAll(fields);
  request.files.add(
    http.MultipartFile.fromBytes(
      fileField,
      fileBytes,
      filename: fileName,
    ),
  );

  final streamed = await request.send().timeout(const Duration(seconds: 30));
  return http.Response.fromStream(streamed);
}
