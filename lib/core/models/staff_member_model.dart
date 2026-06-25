class StaffMemberModel {
  final String userId;
  final String userName;
  final String roleCode;
  final String? groupName;
  final bool permChildEdit;
  final bool permReportEdit;
  final bool permAttendanceEdit;
  final bool permEventEdit;

  const StaffMemberModel({
    required this.userId,
    required this.userName,
    required this.roleCode,
    this.groupName,
    this.permChildEdit = false,
    this.permReportEdit = false,
    this.permAttendanceEdit = false,
    this.permEventEdit = false,
  });

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      userId: json['userId']?.toString() ?? '',
      userName: json['userNm']?.toString() ?? '',
      roleCode: json['roleCd']?.toString() ?? '',
      groupName: json['groupNm']?.toString(),
      permChildEdit: _isYes(json['permChildEdit']),
      permReportEdit: _isYes(json['permReportEdit']),
      permAttendanceEdit: _isYes(json['permAttendanceEdit']),
      permEventEdit: _isYes(json['permEventEdit']),
    );
  }

  StaffMemberModel copyWith({
    String? groupName,
    bool? permChildEdit,
    bool? permReportEdit,
    bool? permAttendanceEdit,
    bool? permEventEdit,
  }) {
    return StaffMemberModel(
      userId: userId,
      userName: userName,
      roleCode: roleCode,
      groupName: groupName ?? this.groupName,
      permChildEdit: permChildEdit ?? this.permChildEdit,
      permReportEdit: permReportEdit ?? this.permReportEdit,
      permAttendanceEdit: permAttendanceEdit ?? this.permAttendanceEdit,
      permEventEdit: permEventEdit ?? this.permEventEdit,
    );
  }

  static bool _isYes(dynamic value) =>
      value?.toString().toUpperCase() == 'Y';
}
