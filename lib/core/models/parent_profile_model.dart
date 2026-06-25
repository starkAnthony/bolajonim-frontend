class ParentProfileModel {
  final String userId;
  final String userName;
  final String? phone;
  final String? email;
  final String? roleCode;

  const ParentProfileModel({
    required this.userId,
    required this.userName,
    this.phone,
    this.email,
    this.roleCode,
  });

  factory ParentProfileModel.fromJson(Map<String, dynamic> json) {
    return ParentProfileModel(
      userId: json['userId']?.toString() ?? '',
      userName: json['userNm']?.toString() ?? '',
      phone: json['userHpTelNo']?.toString(),
      email: json['emlAdr']?.toString(),
      roleCode: json['rofcCd']?.toString(),
    );
  }
}
