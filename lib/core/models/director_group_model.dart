class DirectorGroupModel {
  final String groupNo;
  final String groupName;
  final int? ageMinYr;
  final int? ageMaxYr;
  final int childCount;
  final int teacherCount;

  const DirectorGroupModel({
    required this.groupNo,
    required this.groupName,
    this.ageMinYr,
    this.ageMaxYr,
    this.childCount = 0,
    this.teacherCount = 0,
  });

  factory DirectorGroupModel.fromJson(Map<String, dynamic> json) {
    return DirectorGroupModel(
      groupNo: json['groupNo']?.toString() ?? '',
      groupName: json['groupNm']?.toString() ?? '',
      ageMinYr: _parseInt(json['ageMinYr']),
      ageMaxYr: _parseInt(json['ageMaxYr']),
      childCount: _parseInt(json['childCount']) ?? 0,
      teacherCount: _parseInt(json['teacherCount']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String get ageRangeLabel {
    if (ageMinYr != null && ageMaxYr != null) {
      return '$ageMinYr–$ageMaxYr yosh';
    }
    if (ageMinYr != null) return '$ageMinYr+ yosh';
    if (ageMaxYr != null) return 'gacha $ageMaxYr yosh';
    return 'Yosh oralig‘i kiritilmagan';
  }

  DirectorGroupModel copyWith({
    String? groupNo,
    String? groupName,
    int? ageMinYr,
    int? ageMaxYr,
    int? childCount,
    int? teacherCount,
  }) {
    return DirectorGroupModel(
      groupNo: groupNo ?? this.groupNo,
      groupName: groupName ?? this.groupName,
      ageMinYr: ageMinYr ?? this.ageMinYr,
      ageMaxYr: ageMaxYr ?? this.ageMaxYr,
      childCount: childCount ?? this.childCount,
      teacherCount: teacherCount ?? this.teacherCount,
    );
  }
}
