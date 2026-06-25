class StaffChildFormModel {
  final String? childNo;
  final String childName;
  final String? nickname;
  final String birthDate;
  final String genderCode;
  final String groupName;

  const StaffChildFormModel({
    this.childNo,
    required this.childName,
    this.nickname,
    required this.birthDate,
    required this.genderCode,
    required this.groupName,
  });

  Map<String, dynamic> toJson() {
    return {
      if (childNo != null && childNo!.isNotEmpty) 'childNo': childNo,
      'childNm': childName,
      'nickNm': nickname ?? '',
      'birthDt': birthDate,
      'genderCd': genderCode,
      'groupNm': groupName,
    };
  }
}
