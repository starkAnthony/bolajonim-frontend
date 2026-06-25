class ScheduleItemModel {
  final int? scheduleNo;
  final String startTime;
  final String title;
  final String subtitle;
  final String itemType;

  const ScheduleItemModel({
    this.scheduleNo,
    required this.startTime,
    required this.title,
    required this.subtitle,
    required this.itemType,
  });

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return ScheduleItemModel(
      scheduleNo: json['scheduleNo'] is int
          ? json['scheduleNo'] as int
          : int.tryParse(json['scheduleNo']?.toString() ?? ''),
      startTime: json['startTime']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? 'study',
    );
  }
}

class ScheduleDayModel {
  final String scheduleDate;
  final String teacherNote;
  final List<ScheduleItemModel> items;

  const ScheduleDayModel({
    required this.scheduleDate,
    required this.teacherNote,
    required this.items,
  });

  factory ScheduleDayModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .map(
              (item) =>
                  ScheduleItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList()
        : <ScheduleItemModel>[];

    return ScheduleDayModel(
      scheduleDate: json['scheduleDt']?.toString() ?? '',
      teacherNote: json['teacherNote']?.toString() ?? '',
      items: items,
    );
  }
}
