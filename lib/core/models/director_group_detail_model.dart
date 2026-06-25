import '../models/announcement_model.dart';
import '../models/director_group_model.dart';
import '../models/staff_member_model.dart';
import '../models/teacher_class_child_model.dart';

class DirectorGroupDetailModel {
  final DirectorGroupModel group;
  final List<TeacherClassChildModel> children;
  final List<StaffMemberModel> teachers;
  final List<AnnouncementModel> announcements;

  const DirectorGroupDetailModel({
    required this.group,
    required this.children,
    required this.teachers,
    required this.announcements,
  });

  factory DirectorGroupDetailModel.fromJson(Map<String, dynamic> json) {
    final groupJson = json['group'] as Map<String, dynamic>? ?? {};
    final children = (json['children'] as List<dynamic>? ?? [])
        .map((e) => TeacherClassChildModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final teachers = (json['teachers'] as List<dynamic>? ?? [])
        .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final announcements = (json['announcements'] as List<dynamic>? ?? [])
        .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DirectorGroupDetailModel(
      group: DirectorGroupModel.fromJson(groupJson),
      children: children,
      teachers: teachers,
      announcements: announcements,
    );
  }
}
