import 'dart:html' as html;

void writeSplashCache(String? imageUrl, String? caption) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    html.window.localStorage['bolajonim_splash_url'] = imageUrl;
  } else {
    html.window.localStorage.remove('bolajonim_splash_url');
  }

  if (caption != null && caption.isNotEmpty) {
    html.window.localStorage['bolajonim_splash_caption'] = caption;
  } else {
    html.window.localStorage.remove('bolajonim_splash_caption');
  }
}
