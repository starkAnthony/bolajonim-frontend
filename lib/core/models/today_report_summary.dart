import '../utils/html_text.dart';

class TodayReportSummary {
  final int? reportNo;
  final String childNo;
  final String reportType;
  final String? previewText;

  const TodayReportSummary({
    this.reportNo,
    required this.childNo,
    this.reportType = 'daily',
    this.previewText,
  });

  factory TodayReportSummary.fromJson(Map<String, dynamic> json) {
    return TodayReportSummary(
      reportNo: json['reportNo'] is int
          ? json['reportNo'] as int
          : int.tryParse(json['reportNo']?.toString() ?? ''),
      childNo: json['childNo']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'daily',
      previewText: decodeHtmlText(json['previewText']?.toString()),
    );
  }

  bool get hasContent => previewText?.trim().isNotEmpty == true;

  String get typeLabel {
    switch (reportType.toLowerCase()) {
      case 'health':
        return 'Sog\'liq ko\'rik';
      default:
        return 'Kunlik hisobot';
    }
  }

  /// Parses health preview lines like "Bo'y: 22 sm · Vazn: 11 kg".
  List<({String label, String value})> get metricRows {
    final text = previewText?.trim();
    if (text == null || text.isEmpty) return const [];

    return text.split('·').map((part) {
      final segment = part.trim();
      final colon = segment.indexOf(':');
      if (colon <= 0) {
        return (label: segment, value: '');
      }
      return (
        label: segment.substring(0, colon).trim(),
        value: segment.substring(colon + 1).trim(),
      );
    }).where((row) => row.label.isNotEmpty).toList();
  }
}
