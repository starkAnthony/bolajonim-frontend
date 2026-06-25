import '../config/api_config.dart';
import '../models/daily_report_field_template_model.dart';
import '../models/director_announcement_form_model.dart';
import '../models/director_group_detail_model.dart';
import '../models/director_group_form_model.dart';
import '../models/director_group_model.dart';
import '../models/announcement_model.dart';
import '../models/splash_config_model.dart';
import '../models/director_dashboard_model.dart';
import '../models/staff_child_form_model.dart';
import '../models/staff_member_model.dart';
import '../models/staff_personal_profile_model.dart';
import '../models/staff_profile_model.dart';
import '../models/teacher_class_child_model.dart';
import '../models/teacher_home_model.dart';
import '../models/teacher_message_model.dart';
import '../models/teacher_report_form_model.dart';
import '../models/teacher_report_model.dart';
import '../models/report_detail_model.dart';
import '../models/report_comment_model.dart';
import 'api_client.dart';
import 'bolajonim_api.dart';

class TeacherApi {
  static Future<StaffProfileModel> getProfile() async {
    final body = await ApiClient.get(ApiConfig.staffProfilePath);
    return StaffProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<TeacherHomeModel> getHome() async {
    final body = await ApiClient.get(ApiConfig.staffHomePath);
    return TeacherHomeModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<List<TeacherClassChildModel>> getClassChildren() async {
    final body = await ApiClient.get(ApiConfig.staffClassPath);
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => TeacherClassChildModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<TeacherReportModel>> getReports({bool mineOnly = false}) async {
    final body = await ApiClient.get(
      ApiConfig.staffReportsPath,
      queryParameters: mineOnly ? {'mineOnly': 'true'} : null,
    );
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => TeacherReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<StaffPersonalProfileModel> getStaffPersonalProfile() async {
    final body = await ApiClient.get(ApiConfig.staffPersonalProfilePath);
    return StaffPersonalProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<StaffPersonalProfileModel> getTeacherPersonalProfileForDirector(
    String userId,
  ) async {
    final body = await ApiClient.get(
      ApiConfig.directorStaffPersonalPath,
      queryParameters: {'userId': userId},
    );
    return StaffPersonalProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<StaffPersonalProfileModel> updateStaffPersonalProfile({
    required String userName,
    String? nickName,
    int? ageYr,
    String? homeAddress,
    String? profileNote,
  }) async {
    final body = await ApiClient.put(
      ApiConfig.staffPersonalProfilePath,
      body: {
        'userNm': userName,
        if (nickName != null) 'nickNm': nickName,
        if (ageYr != null) 'ageYr': ageYr,
        if (homeAddress != null) 'homeAddress': homeAddress,
        if (profileNote != null) 'profileNote': profileNote,
      },
    );
    return StaffPersonalProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<StaffPersonalProfileModel> uploadStaffPhoto({
    required List<int> fileBytes,
    String fileName = 'staff-photo.jpg',
  }) async {
    final body = await ApiClient.postMultipart(
      ApiConfig.staffProfilePhotoPath,
      fields: const {},
      fileField: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return StaffPersonalProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<void> deleteStaffPhoto() async {
    await ApiClient.delete(ApiConfig.staffProfilePhotoPath);
  }

  static Future<TeacherReportModel> createReport(TeacherReportFormModel form) async {
    final body = await ApiClient.post(
      ApiConfig.staffReportsPath,
      body: form.toJson(),
    );
    return TeacherReportModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ReportDetailModel> getReportDetail(int reportNo) async {
    final body = await ApiClient.get(
      ApiConfig.staffReportDetailPath,
      queryParameters: {'reportNo': '$reportNo'},
    );
    return ReportDetailModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<List<ReportCommentModel>> getReportComments(int reportNo) async {
    final body = await ApiClient.get(
      ApiConfig.staffReportCommentsPath,
      queryParameters: {'reportNo': '$reportNo'},
    );
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => ReportCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ReportCommentModel> postReportComment({
    required int reportNo,
    required String commentText,
    int? parentCommentNo,
  }) async {
    final body = await ApiClient.post(
      ApiConfig.staffReportCommentsPath,
      body: {
        'reportNo': reportNo,
        'commentText': commentText,
        if (parentCommentNo != null) 'parentCommentNo': parentCommentNo,
      },
    );
    return ReportCommentModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<TeacherReportModel> updateReport({
    required int reportNo,
    required String previewText,
    List<Map<String, dynamic>>? sections,
  }) async {
    final body = await ApiClient.put(
      ApiConfig.staffReportsPath,
      body: {
        'reportNo': reportNo,
        'previewText': previewText,
        if (sections != null) 'sections': sections,
      },
    );
    return TeacherReportModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<void> deleteReport(int reportNo) async {
    await ApiClient.delete(
      ApiConfig.staffReportsPath,
      queryParameters: {'reportNo': '$reportNo'},
    );
  }

  static Future<List<DailyReportFieldTemplate>> getDailyReportFieldTemplate() async {
    final body = await ApiClient.get(ApiConfig.staffDailyReportTemplatePath);
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) =>
            DailyReportFieldTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<DailyReportFieldTemplate>> saveDailyReportFieldTemplate(
    List<DailyReportFieldTemplate> fields,
  ) async {
    final body = await ApiClient.put(
      ApiConfig.staffDailyReportTemplatePath,
      body: {
        'fields': fields.map((e) => e.toJson()).toList(),
      },
    );
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) =>
            DailyReportFieldTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> uploadReportPhoto({
    required int reportNo,
    required List<int> fileBytes,
    int sortOrder = 0,
    String fileName = 'report-photo.jpg',
  }) async {
    await ApiClient.postMultipart(
      ApiConfig.staffReportPhotosPath,
      fields: {
        'reportNo': '$reportNo',
        'sortOrder': '$sortOrder',
      },
      fileField: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  static Future<List<TeacherMessageModel>> getMessages() async {
    final body = await ApiClient.get(ApiConfig.staffMessagesPath);
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => TeacherMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<DirectorDashboardModel> getDirectorDashboard() async {
    final body = await ApiClient.get(ApiConfig.directorDashboardPath);
    return DirectorDashboardModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<List<StaffMemberModel>> getDirectorStaff({
    bool refresh = false,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.directorStaffPath,
      queryParameters: refresh
          ? {'_': DateTime.now().millisecondsSinceEpoch.toString()}
          : null,
    );
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> updateDirectorStaff({
    required String userId,
    required String groupName,
    required bool permChildEdit,
    required bool permReportEdit,
    required bool permAttendanceEdit,
    required bool permEventEdit,
  }) async {
    await ApiClient.put(
      ApiConfig.directorStaffPath,
      body: {
        'userId': userId,
        'groupNm': groupName.trim(),
        'permChildEdit': permChildEdit ? 'Y' : 'N',
        'permReportEdit': permReportEdit ? 'Y' : 'N',
        'permAttendanceEdit': permAttendanceEdit ? 'Y' : 'N',
        'permEventEdit': permEventEdit ? 'Y' : 'N',
      },
    );
  }

  static Future<void> removeDirectorStaff(String userId) async {
    await ApiClient.delete(
      ApiConfig.directorStaffPath,
      queryParameters: {'userId': userId},
    );
  }

  static Future<TeacherClassChildModel> createDirectorChild(
    StaffChildFormModel form,
  ) async {
    final body = await ApiClient.post(
      ApiConfig.directorChildrenPath,
      body: form.toJson(),
    );
    return TeacherClassChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<TeacherClassChildModel> updateStaffChild(
    StaffChildFormModel form,
  ) async {
    final body = await ApiClient.put(
      ApiConfig.staffChildPath,
      body: form.toJson(),
    );
    return TeacherClassChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<void> deleteDirectorChild(String childNo) async {
    await ApiClient.delete(
      ApiConfig.directorChildrenPath,
      queryParameters: {'childNo': childNo},
    );
  }

  static Future<List<DirectorGroupModel>> getDirectorGroups({
    bool refresh = false,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.directorGroupsPath,
      queryParameters: refresh
          ? {'_': DateTime.now().millisecondsSinceEpoch.toString()}
          : null,
    );
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => DirectorGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<DirectorGroupModel> createDirectorGroup(
    DirectorGroupFormModel form,
  ) async {
    final body = await ApiClient.post(
      ApiConfig.directorGroupsPath,
      body: form.toJson(),
    );
    return DirectorGroupModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<DirectorGroupModel> updateDirectorGroup(
    DirectorGroupFormModel form,
  ) async {
    final body = await ApiClient.put(
      ApiConfig.directorGroupsPath,
      body: form.toJson(),
    );
    return DirectorGroupModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<void> deleteDirectorGroup(String groupNo) async {
    await ApiClient.delete(
      ApiConfig.directorGroupsPath,
      queryParameters: {'groupNo': groupNo},
    );
  }

  static Future<DirectorGroupDetailModel> getDirectorGroupDetail(
    String groupNo, {
    bool refresh = false,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.directorGroupDetailPath,
      queryParameters: {
        'groupNo': groupNo,
        if (refresh) '_': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    return DirectorGroupDetailModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<AnnouncementModel> createDirectorAnnouncement(
    DirectorAnnouncementFormModel form,
  ) async {
    final body = await ApiClient.post(
      ApiConfig.directorAnnouncementsPath,
      body: form.toJson(),
    );
    return AnnouncementModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<SplashConfigModel?> getDirectorSplash() async {
    final body = await ApiClient.get(ApiConfig.directorSplashPath);
    final data = ApiClient.resultData<Map<String, dynamic>?>(body);
    if (data == null || data.isEmpty) return null;
    return SplashConfigModel.fromJson(data);
  }

  static Future<SplashConfigModel> uploadDirectorSplash({
    required List<int> fileBytes,
    String fileName = 'splash.jpg',
    String? caption,
    String? validFrom,
    String? validTo,
  }) async {
    final body = await ApiClient.postMultipart(
      ApiConfig.directorSplashPath,
      fields: {
        if (caption != null && caption.isNotEmpty) 'caption': caption,
        if (validFrom != null && validFrom.isNotEmpty) 'validFrom': validFrom,
        if (validTo != null && validTo.isNotEmpty) 'validTo': validTo,
      },
      fileField: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return SplashConfigModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<void> deleteDirectorSplash(int splashNo) async {
    await ApiClient.delete(
      ApiConfig.directorSplashPath,
      queryParameters: {'splashNo': '$splashNo'},
    );
  }

  static String? resolvePhotoUrl(String? path) =>
      BolajonimApi.resolveMediaUrl(path);
}
