class ReportCommentModel {
  final int commentNo;
  final int reportNo;
  final int? parentCommentNo;
  final String authorUserId;
  final String authorRole;
  final String authorNm;
  final String? authorPhotoUrl;
  final String commentText;
  final String? createdAt;

  const ReportCommentModel({
    required this.commentNo,
    required this.reportNo,
    this.parentCommentNo,
    required this.authorUserId,
    required this.authorRole,
    required this.authorNm,
    this.authorPhotoUrl,
    required this.commentText,
    this.createdAt,
  });

  factory ReportCommentModel.fromJson(Map<String, dynamic> json) {
    return ReportCommentModel(
      commentNo: (json['commentNo'] as num?)?.toInt() ?? 0,
      reportNo: (json['reportNo'] as num?)?.toInt() ?? 0,
      parentCommentNo: (json['parentCommentNo'] as num?)?.toInt(),
      authorUserId: json['authorUserId'] as String? ?? '',
      authorRole: json['authorRole'] as String? ?? '',
      authorNm: json['authorNm'] as String? ?? '',
      authorPhotoUrl: json['authorPhotoUrl']?.toString(),
      commentText: json['commentText'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }

  String get roleLabel {
    switch (authorRole.toLowerCase()) {
      case 'parent':
        return 'Ota-ona';
      case 'director':
        return 'Rahbar';
      case 'teacher':
        return 'O\'qituvchi';
      default:
        return authorRole;
    }
  }
}
