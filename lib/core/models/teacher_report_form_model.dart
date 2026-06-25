import 'report_section_model.dart';

class TeacherReportFormModel {
  final String childNo;
  final String reportType;
  final String? previewText;
  final String? weatherCd;
  final List<ReportSectionModel> sections;

  const TeacherReportFormModel({
    required this.childNo,
    required this.reportType,
    this.previewText,
    this.weatherCd,
    this.sections = const [],
  });

  Map<String, dynamic> toJson() => {
        'childNo': childNo,
        'reportType': reportType,
        if (previewText != null && previewText!.trim().isNotEmpty)
          'previewText': previewText!.trim(),
        if (weatherCd != null && weatherCd!.trim().isNotEmpty)
          'weatherCd': weatherCd!.trim(),
        if (sections.isNotEmpty)
          'sections': sections.map((e) => e.toJson()).toList(),
      };
}
