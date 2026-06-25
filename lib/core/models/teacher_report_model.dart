import '../utils/html_text.dart';

class TeacherReportModel {
  final int reportNo;
  final String childNo;
  final String childName;
  final String reportType;
  final String reportDate;
  final String? previewText;
  final String? coverPhotoUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? reportStatus;
  final String? useYn;
  final String? writerUserId;
  final String? writerName;
  final String? weather;

  const TeacherReportModel({
    required this.reportNo,
    required this.childNo,
    required this.childName,
    this.reportType = 'daily',
    required this.reportDate,
    this.previewText,
    this.coverPhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.reportStatus,
    this.useYn,
    this.writerUserId,
    this.writerName,
    this.weather,
  });

  bool get isDeleted =>
      (useYn ?? '').toUpperCase() == 'N' ||
      (reportStatus ?? '').toLowerCase() == 'deleted';

  bool get isEdited => (reportStatus ?? '').toLowerCase() == 'edited';

  factory TeacherReportModel.fromJson(Map<String, dynamic> json) {
    return TeacherReportModel(
      reportNo: int.tryParse(json['reportNo']?.toString() ?? '') ?? 0,
      childNo: json['childNo']?.toString() ?? '',
      childName: json['childNm']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'daily',
      reportDate: json['reportDt']?.toString() ?? '',
      previewText: decodeHtmlText(json['previewText']?.toString()),
      coverPhotoUrl: json['coverPhotoUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      reportStatus: json['reportStatus']?.toString(),
      useYn: json['useYn']?.toString(),
      writerUserId: json['writerUserId']?.toString(),
      writerName: json['writerNm']?.toString(),
      weather: json['weatherCd']?.toString(),
    );
  }
}
