class StaffPersonalProfileModel {
  final String userId;
  final String userName;
  final String? nickName;
  final int? ageYr;
  final String? homeAddress;
  final String? photoUrl;
  final String? profileNote;
  final String roleCode;

  const StaffPersonalProfileModel({
    required this.userId,
    required this.userName,
    this.nickName,
    this.ageYr,
    this.homeAddress,
    this.photoUrl,
    this.profileNote,
    this.roleCode = '',
  });

  factory StaffPersonalProfileModel.fromJson(Map<String, dynamic> json) {
    return StaffPersonalProfileModel(
      userId: json['userId']?.toString() ?? '',
      userName: json['userNm']?.toString() ?? '',
      nickName: json['nickNm']?.toString(),
      ageYr: (json['ageYr'] as num?)?.toInt(),
      homeAddress: json['homeAddress']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      profileNote: json['profileNote']?.toString(),
      roleCode: json['roleCd']?.toString() ?? '',
    );
  }

  String get roleLabel {
    switch (roleCode.toUpperCase()) {
      case 'DIRECTOR':
        return 'Direktor';
      case 'TEACHER':
        return 'O\'qituvchi';
      default:
        return roleCode;
    }
  }
}
