import 'dart:js_util' as js_util;

void dismissHtmlSplash() {
  js_util.callMethod(
    js_util.globalThis,
    'hideBolajonimSplash',
    const [],
  );
}

void resetWebAppearance() {
  js_util.callMethod(
    js_util.globalThis,
    'resetBolajonimWebAppearance',
    const [],
  );
}
