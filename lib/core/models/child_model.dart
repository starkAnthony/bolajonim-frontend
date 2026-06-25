class ChildModel {
  final String childNo;
  final String childName;
  final String? nickname;
  final String? birthDate;
  final String? gender;
  final String? groupName;
  final String? kindergartenName;
  final String? photoUrl;
  final String? relation;

  const ChildModel({
    required this.childNo,
    required this.childName,
    this.nickname,
    this.birthDate,
    this.gender,
    this.groupName,
    this.kindergartenName,
    this.photoUrl,
    this.relation,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      childNo: json['childNo']?.toString() ?? '',
      childName: json['childNm']?.toString() ?? '',
      nickname: json['nickNm']?.toString(),
      birthDate: json['birthDt']?.toString(),
      gender: json['genderCd']?.toString(),
      groupName: json['groupNm']?.toString(),
      kindergartenName: json['kgNm']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      relation: json['relationNm']?.toString(),
    );
  }

  String get displaySubtitle {
    final parts = <String>[];
    if (kindergartenName != null && kindergartenName!.isNotEmpty) {
      parts.add(kindergartenName!);
    }
    if (groupName != null && groupName!.isNotEmpty) {
      parts.add(groupName!);
    }
    return parts.join(' • ');
  }
}
