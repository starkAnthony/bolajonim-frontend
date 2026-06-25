class DailyReportFieldTemplate {
  final int? fieldNo;
  final String fieldKey;
  final String label;
  final String fieldType;
  final List<String> choices;
  final int sortOrder;
  final bool required;

  const DailyReportFieldTemplate({
    this.fieldNo,
    required this.fieldKey,
    required this.label,
    this.fieldType = 'choice',
    this.choices = const [],
    this.sortOrder = 0,
    this.required = true,
  });

  bool get isChoice => fieldType.toLowerCase() == 'choice';

  factory DailyReportFieldTemplate.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'] as List<dynamic>? ?? [];
    return DailyReportFieldTemplate(
      fieldNo: json['fieldNo'] is int
          ? json['fieldNo'] as int
          : int.tryParse(json['fieldNo']?.toString() ?? ''),
      fieldKey: json['fieldKey']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fieldType: json['fieldType']?.toString() ?? 'choice',
      choices: rawChoices.map((e) => e.toString()).toList(),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      required: json['required'] == true ||
          (json['required']?.toString() ?? '') == '1',
    );
  }

  Map<String, dynamic> toJson() => {
        if (fieldNo != null) 'fieldNo': fieldNo,
        'fieldKey': fieldKey,
        'label': label,
        'fieldType': fieldType,
        'choices': choices,
        'sortOrder': sortOrder,
        'required': required,
      };
}
