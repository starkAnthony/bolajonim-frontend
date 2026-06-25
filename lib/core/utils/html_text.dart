/// Decodes HTML entities returned by the Taskhub XSS filter (e.g. &#39; → ').
String decodeHtmlText(String? value) {
  if (value == null || value.isEmpty) return value ?? '';

  return value
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
}
