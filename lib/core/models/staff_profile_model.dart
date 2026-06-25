class StaffProfileModel {
  final String userId;
  final String userName;
  final String roleCode;
  final String? kgName;
  final String? groupName;
  final String? inviteCode;
  final bool isDirector;
  final bool permChildEdit;
  final bool permReportEdit;
  final bool permAttendanceEdit;
  final bool permEventEdit;

  const StaffProfileModel({
    required this.userId,
    required this.userName,
    required this.roleCode,
    this.kgName,
    this.groupName,
    this.inviteCode,
    this.isDirector = false,
    this.permChildEdit = false,
    this.permReportEdit = false,
    this.permAttendanceEdit = false,
    this.permEventEdit = false,
  });

  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    return StaffProfileModel(
      userId: json['userId']?.toString() ?? '',
      userName: json['userNm']?.toString() ?? '',
      roleCode: json['roleCd']?.toString() ?? '',
      kgName: json['kgNm']?.toString(),
      groupName: json['groupNm']?.toString(),
      inviteCode: json['inviteCode']?.toString(),
      isDirector: json['director'] == true,
      permChildEdit: json['permChildEdit'] == true,
      permReportEdit: json['permReportEdit'] == true,
      permAttendanceEdit: json['permAttendanceEdit'] == true,
      permEventEdit: json['permEventEdit'] == true,
    );
  }
}
