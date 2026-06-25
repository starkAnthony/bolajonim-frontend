class DirectorAnnouncementFormModel {
  final String title;
  final String content;
  final String type;
  final bool isImportant;
  final String? groupName;

  const DirectorAnnouncementFormModel({
    required this.title,
    required this.content,
    this.type = 'announcement',
    this.isImportant = false,
    this.groupName,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'annType': type,
      'isImportant': isImportant ? 'Y' : 'N',
      if (groupName != null && groupName!.isNotEmpty) 'groupNm': groupName,
    };
  }
}
