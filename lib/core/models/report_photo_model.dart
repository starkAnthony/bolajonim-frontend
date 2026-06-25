class ReportPhotoModel {
  final int photoNo;
  final int reportNo;
  final String imageUrl;
  final String? caption;
  final int sortOrder;

  const ReportPhotoModel({
    required this.photoNo,
    required this.reportNo,
    required this.imageUrl,
    this.caption,
    this.sortOrder = 0,
  });

  factory ReportPhotoModel.fromJson(Map<String, dynamic> json) {
    return ReportPhotoModel(
      photoNo: int.tryParse(json['photoNo']?.toString() ?? '') ?? 0,
      reportNo: int.tryParse(json['reportNo']?.toString() ?? '') ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      caption: json['caption']?.toString(),
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
    );
  }
}
