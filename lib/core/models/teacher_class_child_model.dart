class TeacherClassChildModel {
  final String childNo;
  final String childName;
  final String? nickname;
  final String? photoUrl;
  final String todayStatus;
  final String? groupName;
  final String? birthDate;
  final String? genderCode;

  const TeacherClassChildModel({
    required this.childNo,
    required this.childName,
    this.nickname,
    this.photoUrl,
    required this.todayStatus,
    this.groupName,
    this.birthDate,
    this.genderCode,
  });

  factory TeacherClassChildModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassChildModel(
      childNo: json['childNo']?.toString() ?? '',
      childName: json['childNm']?.toString() ?? '',
      nickname: json['nickNm']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      todayStatus: json['todayStatus']?.toString() ?? 'pending',
      groupName: json['groupNm']?.toString(),
      birthDate: json['birthDt']?.toString(),
      genderCode: json['genderCd']?.toString(),
    );
  }

  String get displayStatus {
    switch (todayStatus.toLowerCase()) {
      case 'present':
        return 'Keldi';
      case 'absent':
        return 'Kelmadi';
      default:
        return 'Kutilmoqda';
    }
  }

  /// Group / nickname line for director management screens (not attendance).
  String? get managementSubtitle {
    final parts = <String>[];
    if (groupName != null && groupName!.trim().isNotEmpty) {
      parts.add(groupName!.trim());
    }
    if (nickname != null && nickname!.trim().isNotEmpty) {
      parts.add(nickname!.trim());
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
