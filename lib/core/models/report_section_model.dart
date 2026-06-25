import '../utils/html_text.dart';

class ReportTableRowModel {
  final String? fieldKey;
  final String label;
  final String value;

  const ReportTableRowModel({
    this.fieldKey,
    required this.label,
    required this.value,
  });

  factory ReportTableRowModel.fromJson(Map<String, dynamic> json) {
    return ReportTableRowModel(
      fieldKey: json['fieldKey']?.toString(),
      label: decodeHtmlText(json['label']?.toString() ?? ''),
      value: decodeHtmlText(json['value']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        if (fieldKey != null && fieldKey!.trim().isNotEmpty)
          'fieldKey': fieldKey!.trim(),
        'label': label,
        'value': value,
      };
}

class ReportSectionModel {
  final String sectionType;
  final String? title;
  final String? bodyText;
  final List<ReportTableRowModel> rows;

  const ReportSectionModel({
    required this.sectionType,
    this.title,
    this.bodyText,
    this.rows = const [],
  });

  factory ReportSectionModel.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'] as List<dynamic>? ?? [];
    return ReportSectionModel(
      sectionType: json['sectionType']?.toString() ?? 'text',
      title: decodeHtmlText(json['title']?.toString()),
      bodyText: decodeHtmlText(json['bodyText']?.toString()),
      rows: rawRows
          .map((e) => ReportTableRowModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sectionType': sectionType,
        if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
        if (bodyText != null && bodyText!.trim().isNotEmpty)
          'bodyText': bodyText!.trim(),
        if (rows.isNotEmpty) 'rows': rows.map((e) => e.toJson()).toList(),
      };
}
