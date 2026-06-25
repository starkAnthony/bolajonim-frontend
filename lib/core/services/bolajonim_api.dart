import '../config/api_config.dart';
import 'api_client.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/child_model.dart';
import '../models/daily_report_model.dart';
import '../models/gallery_model.dart';
import '../models/home_model.dart';
import '../models/meal_model.dart';
import '../models/parent_profile_model.dart';
import '../models/pickup_model.dart';
import '../models/report_detail_model.dart';
import '../models/report_comment_model.dart';
import '../models/schedule_model.dart';

class BolajonimApi {
  static Future<bool> isUserIdTaken(String userId) async {
    return _isDuplicate(
      ApiConfig.checkUserIdDuplicatePath,
      {'userId': userId.trim()},
    );
  }

  static Future<bool> isEmailTaken(String email) async {
    return _isDuplicate(
      ApiConfig.checkEmailDuplicatePath,
      {'emlAdr': email.trim().toLowerCase()},
    );
  }

  static Future<bool> isPhoneTaken(String phone) async {
    return _isDuplicate(
      ApiConfig.checkPhoneDuplicatePath,
      {'userHpTelNo': phone.replaceAll(RegExp(r'[^0-9]'), '')},
    );
  }

  static Future<bool> _isDuplicate(
    String path,
    Map<String, String> queryParameters,
  ) async {
    final body = await ApiClient.get(
      path,
      queryParameters: queryParameters,
      authenticated: false,
    );

    final result = ApiClient.resultData<Map<String, dynamic>>(body);
    return result['duplicated'] == true;
  }

  static Future<String> resolveLoginId({
    required String loginValue,
    required String loginType,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.resolveLoginPath,
      queryParameters: {
        'loginValue': loginValue,
        'loginType': loginType,
      },
      authenticated: false,
    );

    final result = ApiClient.resultData<Map<String, dynamic>>(body);
    final found = result['found'] == true;
    final userId = result['userId']?.toString();

    if (!found || userId == null || userId.isEmpty) {
      throw Exception(result['message']?.toString() ?? 'User not found');
    }

    return userId;
  }

  static Future<void> resetPassword({
    required String newPassword,
    String? phone,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'userPwd': newPassword,
    };

    if (phone != null && phone.isNotEmpty) {
      body['userHpTelNo'] = phone.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (email != null && email.isNotEmpty) {
      body['emlAdr'] = email.trim().toLowerCase();
    }

    final response = await ApiClient.post(
      ApiConfig.resetPasswordPath,
      body: body,
      authenticated: false,
    );

    final result = ApiClient.resultData<Map<String, dynamic>>(response);
    if (result['success'] != true) {
      final message = result['message']?.toString() ?? 'Failed to reset password.';
      throw Exception(message);
    }
  }

  static Future<String> validateKindergartenInvite(String inviteCode) async {
    final body = await ApiClient.get(
      ApiConfig.kindergartenValidatePath,
      queryParameters: {'inviteCode': inviteCode.trim()},
      authenticated: false,
    );
    final result = ApiClient.resultData<Map<String, dynamic>>(body);
    return result['kgNm']?.toString() ?? '';
  }

  static Future<ChildModel> lookupChildForLink({
    required String childName,
    required String birthday,
    required String inviteCode,
  }) async {
    final body = await ApiClient.post(
      ApiConfig.childLookupPath,
      body: {
        'childNm': _sanitizeApiText(childName),
        'birthDt': _toApiDate(birthday),
        'inviteCode': inviteCode.trim(),
      },
    );

    return ChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ChildModel> linkChild({
    required String childName,
    required String birthday,
    required String inviteCode,
    required String relation,
  }) async {
    final body = await ApiClient.post(
      ApiConfig.childRegisterPath,
      body: {
        'childNm': _sanitizeApiText(childName),
        'birthDt': _toApiDate(birthday),
        'inviteCode': inviteCode.trim(),
        'relationNm': _sanitizeApiText(relation),
      },
    );

    return ChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<List<ChildModel>> getChildren() async {
    final body = await ApiClient.get(ApiConfig.childrenPath);
    final list = ApiClient.resultData<List<dynamic>>(body);

    return list
        .map((item) => ChildModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<HomeModel> getHome({String? childNo}) async {
    final body = await ApiClient.get(
      ApiConfig.homePath,
      queryParameters: childNo == null ? null : {'childNo': childNo},
    );

    return HomeModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ParentProfileModel> getProfile() async {
    final body = await ApiClient.get(ApiConfig.profilePath);
    return ParentProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ParentProfileModel> updateProfile({
    required String userName,
    String? phone,
    String? email,
  }) async {
    final body = await ApiClient.put(
      ApiConfig.profilePath,
      body: {
        'userNm': _sanitizeApiText(userName),
        if (phone != null && phone.isNotEmpty)
          'userHpTelNo': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        if (email != null && email.isNotEmpty)
          'emlAdr': email.trim().toLowerCase(),
      },
    );

    return ParentProfileModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ChildModel> updateChild({
    required String childNo,
    required String childName,
    String? nickname,
    required String birthday,
    required String gender,
    required String groupName,
    String? relation,
  }) async {
    final body = await ApiClient.put(
      ApiConfig.childUpdatePath,
      body: {
        'childNo': childNo,
        'childNm': _sanitizeApiText(childName),
        'nickNm': _sanitizeApiText(nickname ?? ''),
        'birthDt': _toApiDate(birthday),
        'genderCd': _toApiGender(gender),
        'groupNm': _sanitizeApiText(groupName),
        if (relation != null && relation.isNotEmpty)
          'relationNm': _sanitizeApiText(relation),
      },
    );

    return ChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ChildModel> uploadChildPhoto({
    required String childNo,
    required List<int> fileBytes,
    String fileName = 'child-photo.jpg',
  }) async {
    final body = await ApiClient.postMultipart(
      ApiConfig.childPhotoPath,
      fields: {'childNo': childNo},
      fileField: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
    );

    return ChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<ChildModel> deleteChildPhoto({required String childNo}) async {
    final body = await ApiClient.delete(
      ApiConfig.childPhotoPath,
      queryParameters: {'childNo': childNo},
    );

    return ChildModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static String? resolveMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiConfig.baseUrl}$path';
  }

  static String formatApiDateForDisplay(String? value) {
    if (value == null || value.length != 8) return '';
    return '${value.substring(6, 8)}.${value.substring(4, 6)}.${value.substring(0, 4)}';
  }

  static Future<List<AnnouncementModel>> getAnnouncements({
    String? childNo,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.announcementsPath,
      queryParameters: childNo == null ? null : {'childNo': childNo},
    );

    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((item) => AnnouncementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<DailyReportModel>> getReports({
    String? childNo,
    String? reportMonth,
  }) async {
    final query = <String, String>{};
    if (childNo != null && childNo.isNotEmpty) query['childNo'] = childNo;
    if (reportMonth != null && reportMonth.isNotEmpty) {
      query['reportMonth'] = reportMonth;
    }

    final body = await ApiClient.get(
      ApiConfig.reportsPath,
      queryParameters: query.isEmpty ? null : query,
    );

    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((item) => DailyReportModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ReportDetailModel> getReportDetail({
    required int reportNo,
    required String childNo,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.reportDetailPath,
      queryParameters: {
        'reportNo': '$reportNo',
        'childNo': childNo,
      },
    );
    return ReportDetailModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<List<ReportCommentModel>> getReportComments({
    required int reportNo,
    required String childNo,
  }) async {
    final body = await ApiClient.get(
      ApiConfig.reportCommentsPath,
      queryParameters: {
        'reportNo': '$reportNo',
        'childNo': childNo,
      },
    );
    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((e) => ReportCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ReportCommentModel> postReportComment({
    required int reportNo,
    required String childNo,
    required String commentText,
    int? parentCommentNo,
  }) async {
    final body = await ApiClient.post(
      ApiConfig.reportCommentsPath,
      body: {
        'reportNo': reportNo,
        'childNo': childNo,
        'commentText': commentText,
        if (parentCommentNo != null) 'parentCommentNo': parentCommentNo,
      },
    );
    return ReportCommentModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<List<AttendanceModel>> getAttendance({
    String? childNo,
    String? attendanceMonth,
  }) async {
    final query = <String, String>{};
    if (childNo != null && childNo.isNotEmpty) query['childNo'] = childNo;
    if (attendanceMonth != null && attendanceMonth.isNotEmpty) {
      query['attendanceMonth'] = attendanceMonth;
    }

    final body = await ApiClient.get(
      ApiConfig.attendancePath,
      queryParameters: query.isEmpty ? null : query,
    );

    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<MealModel>> getMeals({
    String? childNo,
    String? mealMonth,
  }) async {
    final query = <String, String>{};
    if (childNo != null && childNo.isNotEmpty) query['childNo'] = childNo;
    if (mealMonth != null && mealMonth.isNotEmpty) {
      query['mealMonth'] = mealMonth;
    }

    final body = await ApiClient.get(
      ApiConfig.mealsPath,
      queryParameters: query.isEmpty ? null : query,
    );

    final list = ApiClient.resultData<List<dynamic>>(body);
    return list
        .map((item) => MealModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ScheduleDayModel> getSchedule({
    String? childNo,
    String? scheduleDt,
  }) async {
    final query = <String, String>{};
    if (childNo != null && childNo.isNotEmpty) query['childNo'] = childNo;
    if (scheduleDt != null && scheduleDt.isNotEmpty) {
      query['scheduleDt'] = scheduleDt;
    }

    final body = await ApiClient.get(
      ApiConfig.schedulePath,
      queryParameters: query.isEmpty ? null : query,
    );

    return ScheduleDayModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<GalleryDayModel> getGallery({
    String? childNo,
    String? galleryDt,
  }) async {
    final query = <String, String>{};
    if (childNo != null && childNo.isNotEmpty) query['childNo'] = childNo;
    if (galleryDt != null && galleryDt.isNotEmpty) {
      query['galleryDt'] = galleryDt;
    }

    final body = await ApiClient.get(
      ApiConfig.galleryPath,
      queryParameters: query.isEmpty ? null : query,
    );

    return GalleryDayModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<PickupModel> getPickup({String? childNo}) async {
    final body = await ApiClient.get(
      ApiConfig.pickupPath,
      queryParameters: childNo == null ? null : {'childNo': childNo},
    );

    return PickupModel.fromJson(
      ApiClient.resultData<Map<String, dynamic>>(body),
    );
  }

  static Future<String?> teacherSignUp({
    required String userId,
    required String userName,
    required String password,
    required String inviteCode,
    required String groupName,
    String? phone,
    String? email,
  }) async {
    final body = await ApiClient.post(
      ApiConfig.teacherSignUpPath,
      body: {
        'userId': userId.trim(),
        'userNm': _sanitizeApiText(userName.trim()),
        'userPwd': password,
        'inviteCode': inviteCode.trim(),
        'groupNm': _sanitizeApiText(groupName.trim()),
        'agreeYn': 'Y',
        if (phone != null && phone.isNotEmpty) 'userHpTelNo': phone,
        if (email != null && email.isNotEmpty) 'emlAdr': email.trim().toLowerCase(),
      },
      authenticated: false,
    );

    final result = ApiClient.resultData<Map<String, dynamic>>(body);
    if (result['success'] == true) return null;
    return result['message']?.toString() ?? 'Ro‘yxatdan o‘tishda xatolik.';
  }

  static Future<String?> directorSignUp({
    required String userId,
    required String userName,
    required String password,
    required String kgName,
    String? kgAddress,
    String? phone,
    String? email,
  }) async {
    final body = await ApiClient.post(
      ApiConfig.directorSignUpPath,
      body: {
        'userId': userId.trim(),
        'userNm': _sanitizeApiText(userName.trim()),
        'userPwd': password,
        'kgNm': _sanitizeApiText(kgName.trim()),
        if (kgAddress != null && kgAddress.isNotEmpty)
          'kgAddress': _sanitizeApiText(kgAddress.trim()),
        'agreeYn': 'Y',
        if (phone != null && phone.isNotEmpty) 'userHpTelNo': phone,
        if (email != null && email.isNotEmpty) 'emlAdr': email.trim().toLowerCase(),
      },
      authenticated: false,
    );

    final result = ApiClient.resultData<Map<String, dynamic>>(body);
    if (result['success'] == true) return null;
    return result['message']?.toString() ?? 'Ro‘yxatdan o‘tishda xatolik.';
  }

  static String _toApiDate(String value) {
    final parts = value.split('.');
    if (parts.length != 3) return value;
    return '${parts[2]}${parts[1]}${parts[0]}';
  }

  static String _toApiGender(String gender) {
    final normalized = gender.trim().toUpperCase();
    if (normalized == 'BOY' ||
        normalized == 'GIRL' ||
        normalized == 'MALE' ||
        normalized == 'FEMALE') {
      return normalized == 'GIRL' || normalized == 'FEMALE' ? 'GIRL' : 'BOY';
    }

    if (normalized.contains('QIZ') || normalized.contains('GIRL')) {
      return 'GIRL';
    }

    return 'BOY';
  }

  static String _sanitizeApiText(String value) {
    return value
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u02BB', "'")
        .replaceAll('\u02BC', "'");
  }
}
