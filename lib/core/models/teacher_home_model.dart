class TeacherHomeModel {
  final String userName;
  final String? kgName;
  final String? groupName;
  final int totalChildren;
  final int presentToday;
  final int absentToday;
  final int pendingPickup;
  final int unreadMessages;
  final List<TeacherScheduleItem> schedule;

  const TeacherHomeModel({
    required this.userName,
    this.kgName,
    this.groupName,
    required this.totalChildren,
    required this.presentToday,
    required this.absentToday,
    required this.pendingPickup,
    required this.unreadMessages,
    this.schedule = const [],
  });

  factory TeacherHomeModel.fromJson(Map<String, dynamic> json) {
    final scheduleJson = json['schedule'] as List<dynamic>? ?? [];
    return TeacherHomeModel(
      userName: json['userNm']?.toString() ?? '',
      kgName: json['kgNm']?.toString(),
      groupName: json['groupNm']?.toString(),
      totalChildren: int.tryParse(json['totalChildren']?.toString() ?? '') ?? 0,
      presentToday: int.tryParse(json['presentToday']?.toString() ?? '') ?? 0,
      absentToday: int.tryParse(json['absentToday']?.toString() ?? '') ?? 0,
      pendingPickup: int.tryParse(json['pendingPickup']?.toString() ?? '') ?? 0,
      unreadMessages: int.tryParse(json['unreadMessages']?.toString() ?? '') ?? 0,
      schedule: scheduleJson
          .map((e) => TeacherScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TeacherScheduleItem {
  final String startTime;
  final String title;
  final String? subtitle;

  const TeacherScheduleItem({
    required this.startTime,
    required this.title,
    this.subtitle,
  });

  factory TeacherScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleItem(
      startTime: json['startTime']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
    );
  }
}
