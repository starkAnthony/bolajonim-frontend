import 'package:http/http.dart' as http;

import 'save_network_image_impl.dart';

class SaveNetworkImage {
  static Future<void> save(String url, {required String fileName}) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Rasm yuklab bo‘lmadi (${response.statusCode})');
    }

    await saveImageBytes(response.bodyBytes, fileName);
  }
}
