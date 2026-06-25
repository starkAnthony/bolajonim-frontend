class DirectorDashboardModel {
  final String kgName;
  final String inviteCode;
  final int teacherCount;
  final int childCount;
  final int groupCount;
  final int unreadMessages;
  final String? latestAnnouncement;

  const DirectorDashboardModel({
    required this.kgName,
    required this.inviteCode,
    required this.teacherCount,
    required this.childCount,
    required this.groupCount,
    required this.unreadMessages,
    this.latestAnnouncement,
  });

  factory DirectorDashboardModel.fromJson(Map<String, dynamic> json) {
    return DirectorDashboardModel(
      kgName: json['kgNm']?.toString() ?? '',
      inviteCode: json['inviteCode']?.toString() ?? '',
      teacherCount: int.tryParse(json['teacherCount']?.toString() ?? '') ?? 0,
      childCount: int.tryParse(json['childCount']?.toString() ?? '') ?? 0,
      groupCount: int.tryParse(json['groupCount']?.toString() ?? '') ?? 0,
      unreadMessages: int.tryParse(json['unreadMessages']?.toString() ?? '') ?? 0,
      latestAnnouncement: json['latestAnnouncement']?.toString(),
    );
  }
}
