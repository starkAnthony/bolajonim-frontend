class TeacherMessageModel {
  final int msgNo;
  final String senderName;
  final String? childName;
  final String? previewText;
  final int unreadCount;
  final String? createdAt;

  const TeacherMessageModel({
    required this.msgNo,
    required this.senderName,
    this.childName,
    this.previewText,
    required this.unreadCount,
    this.createdAt,
  });

  factory TeacherMessageModel.fromJson(Map<String, dynamic> json) {
    return TeacherMessageModel(
      msgNo: int.tryParse(json['msgNo']?.toString() ?? '') ?? 0,
      senderName: json['senderNm']?.toString() ?? '',
      childName: json['childNm']?.toString(),
      previewText: json['previewText']?.toString(),
      unreadCount: int.tryParse(json['unreadCnt']?.toString() ?? '') ?? 0,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
