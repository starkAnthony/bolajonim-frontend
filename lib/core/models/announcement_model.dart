class AnnouncementModel {
  final int? id;
  final String title;
  final String? content;
  final String type;
  final bool isImportant;
  final String? eventDate;
  final String? kindergartenName;
  final String? groupName;
  final String? createdAt;

  const AnnouncementModel({
    this.id,
    required this.title,
    this.content,
    required this.type,
    this.isImportant = false,
    this.eventDate,
    this.kindergartenName,
    this.groupName,
    this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['annNo'] is int
          ? json['annNo'] as int
          : int.tryParse(json['annNo']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString(),
      type: json['annType']?.toString() ?? 'announcement',
      isImportant: (json['isImportant']?.toString() ?? 'N') == 'Y',
      eventDate: json['eventDt']?.toString(),
      kindergartenName: json['kgNm']?.toString(),
      groupName: json['groupNm']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  String get preview {
    final text = content?.trim();
    if (text == null || text.isEmpty) return title;
    return text.length > 120 ? '${text.substring(0, 120)}...' : text;
  }

  DateTime? get parsedCreatedAt => _parseDateTime(createdAt);

  DateTime? get parsedEventDate => _parseEventDate(eventDate);

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = value.trim().replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  static DateTime? _parseEventDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 8) {
      final year = int.tryParse(digits.substring(0, 4));
      final month = int.tryParse(digits.substring(4, 6));
      final day = int.tryParse(digits.substring(6, 8));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(value);
  }
}
