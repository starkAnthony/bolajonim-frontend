import 'report_section_model.dart';
import 'report_photo_model.dart';
import '../utils/html_text.dart';

class ReportDetailModel {
  final int reportNo;
  final String childNo;
  final String reportType;
  final String reportDate;
  final String direction;
  final String? previewText;
  final String? weather;
  final String? writerUserId;
  final String? writerName;
  final String? writerRole;
  final String? writerPhotoUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? reportStatus;
  final String? useYn;
  final List<ReportSectionModel> sections;
  final List<ReportPhotoModel> photos;

  const ReportDetailModel({
    required this.reportNo,
    required this.childNo,
    required this.reportType,
    required this.reportDate,
    required this.direction,
    this.previewText,
    this.weather,
    this.writerUserId,
    this.writerName,
    this.writerRole,
    this.writerPhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.reportStatus,
    this.useYn,
    this.sections = const [],
    this.photos = const [],
  });

  bool get isDeleted =>
      (useYn ?? '').toUpperCase() == 'N' ||
      (reportStatus ?? '').toLowerCase() == 'deleted';

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? [];
    final rawPhotos = json['photos'] as List<dynamic>? ?? [];
    return ReportDetailModel(
      reportNo: int.tryParse(json['reportNo']?.toString() ?? '') ?? 0,
      childNo: json['childNo']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'daily',
      reportDate: json['reportDt']?.toString() ?? '',
      direction: json['directionCd']?.toString() ?? 'centerToHome',
      previewText: decodeHtmlText(json['previewText']?.toString()),
      weather: json['weatherCd']?.toString(),
      writerUserId: json['writerUserId']?.toString(),
      writerName: json['writerNm']?.toString(),
      writerRole: json['writerRole']?.toString(),
      writerPhotoUrl: json['writerPhotoUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      reportStatus: json['reportStatus']?.toString(),
      useYn: json['useYn']?.toString(),
      sections: rawSections
          .map((e) => ReportSectionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: rawPhotos
          .map((e) => ReportPhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get typeLabel {
    switch (reportType.toLowerCase()) {
      case 'health':
        return 'Sog\'liq ko\'rik';
      default:
        return 'Kunlik hisobot';
    }
  }
}
