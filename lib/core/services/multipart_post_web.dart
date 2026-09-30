import 'dart:js_interop';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:web/web.dart';

/// Browser upload that lets Safari build the multipart body.
///
/// package:http sends a hand-built multipart payload and sets Content-Type
/// itself. iPhone Safari then drops the boundary, so Spring cannot see the
/// form fields.
Future<http.Response> sendMultipart({
  required Uri uri,
  required Map<String, String> headers,
  required Map<String, String> fields,
  required String fileField,
  required List<int> fileBytes,
  required String fileName,
}) async {
  final formData = FormData();
  for (final field in fields.entries) {
    formData.append(field.key, field.value.toJS);
  }

  final bytes = Uint8List.fromList(fileBytes);
  final blob = Blob(
    [bytes.toJS].toJS,
    BlobPropertyBag(type: _contentTypeFor(fileName)),
  );
  formData.append(fileField, blob, fileName);

  final requestHeaders = Headers();
  for (final header in headers.entries) {
    if (header.key.toLowerCase() == 'content-type') continue;
    requestHeaders.append(header.key, header.value);
  }

  final response = await window
      .fetch(
        uri.toString().toJS,
        RequestInit(
          method: 'POST',
          body: formData,
          headers: requestHeaders,
        ),
      )
      .toDart;
  final body = (await response.text().toDart).toDart;
  return http.Response(body, response.status);
}

String _contentTypeFor(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}
