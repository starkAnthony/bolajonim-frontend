class AttendanceModel {
  final int? attendanceNo;
  final String childNo;
  final String attendanceDate;
  final String status;
  final String? arrivalTime;
  final String? leavingTime;
  final String? pickupPerson;
  final String? note;

  const AttendanceModel({
    this.attendanceNo,
    required this.childNo,
    required this.attendanceDate,
    required this.status,
    this.arrivalTime,
    this.leavingTime,
    this.pickupPerson,
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceNo: json['attendanceNo'] is int
          ? json['attendanceNo'] as int
          : int.tryParse(json['attendanceNo']?.toString() ?? ''),
      childNo: json['childNo']?.toString() ?? '',
      attendanceDate: json['attendanceDt']?.toString() ?? '',
      status: json['statusCd']?.toString() ?? 'present',
      arrivalTime: json['arrivalTime']?.toString(),
      leavingTime: json['leavingTime']?.toString(),
      pickupPerson: json['pickupPerson']?.toString(),
      note: json['noteText']?.toString(),
    );
  }

  DateTime? get parsedDate {
    final digits = attendanceDate.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 8) return null;

    final year = int.tryParse(digits.substring(0, 4));
    final month = int.tryParse(digits.substring(4, 6));
    final day = int.tryParse(digits.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
}
