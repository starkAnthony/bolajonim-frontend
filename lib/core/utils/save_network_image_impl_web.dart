import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveImageBytes(Uint8List bytes, String fileName) async {
  final blob = html.Blob([bytes]);
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: objectUrl)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(objectUrl);
}
