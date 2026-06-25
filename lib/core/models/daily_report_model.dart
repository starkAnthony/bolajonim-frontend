import '../utils/html_text.dart';

class DailyReportModel {
  final int? reportNo;
  final String childNo;
  final String reportType;
  final String reportDate;
  final String direction;
  final String? previewText;
  final String? weather;
  final String? createdAt;
  final String? updatedAt;
  final String? reportStatus;
  final String? useYn;
  final String? coverPhotoUrl;

  const DailyReportModel({
    this.reportNo,
    required this.childNo,
    this.reportType = 'daily',
    required this.reportDate,
    required this.direction,
    this.previewText,
    this.weather,
    this.createdAt,
    this.updatedAt,
    this.reportStatus,
    this.useYn,
    this.coverPhotoUrl,
  });

  bool get isDeleted =>
      (useYn ?? '').toUpperCase() == 'N' ||
      (reportStatus ?? '').toLowerCase() == 'deleted';

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      reportNo: json['reportNo'] is int
          ? json['reportNo'] as int
          : int.tryParse(json['reportNo']?.toString() ?? ''),
      childNo: json['childNo']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'daily',
      reportDate: json['reportDt']?.toString() ?? '',
      direction: json['directionCd']?.toString() ?? 'centerToHome',
      previewText: decodeHtmlText(json['previewText']?.toString()),
      weather: json['weatherCd']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      reportStatus: json['reportStatus']?.toString(),
      useYn: json['useYn']?.toString(),
      coverPhotoUrl: json['coverPhotoUrl']?.toString(),
    );
  }

  DateTime? get parsedDate {
    final digits = reportDate.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 8) return null;

    final year = int.tryParse(digits.substring(0, 4));
    final month = int.tryParse(digits.substring(4, 6));
    final day = int.tryParse(digits.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
}
