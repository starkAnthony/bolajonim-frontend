class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.59:8081',
  );

  static const String loginPath = '/api/v1/athz10/login';
  static const String resolveLoginPath = '/api/v1/flut100/resolveLoginId';
  static const String parentSignUpPath = '/api/v1/flut100/parent/signUp';
  static const String teacherSignUpPath = '/api/v1/flut100/teacher/signUp';
  static const String directorSignUpPath = '/api/v1/flut100/director/signUp';
  static const String checkUserIdDuplicatePath =
      '/api/v1/flut100/checkUserIdDuplicate';
  static const String checkEmailDuplicatePath =
      '/api/v1/flut100/checkEmailDuplicate';
  static const String checkPhoneDuplicatePath =
      '/api/v1/flut100/checkPhoneDuplicate';
  static const String resetPasswordPath = '/api/v1/flut100/parent/resetPassword';
  static const String childRegisterPath = '/api/v1/flut200/child/register';
  static const String childLookupPath = '/api/v1/flut200/child/lookup';
  static const String kindergartenValidatePath = '/api/v1/flut100/kindergarten/validate';
  static const String childrenPath = '/api/v1/flut200/children';
  static const String homePath = '/api/v1/flut200/home';
  static const String profilePath = '/api/v1/flut200/profile';
  static const String childUpdatePath = '/api/v1/flut200/child';
  static const String childPhotoPath = '/api/v1/flut200/child/photo';
  static const String announcementsPath = '/api/v1/flut200/announcements';
  static const String reportsPath = '/api/v1/flut200/reports';
  static const String reportDetailPath = '/api/v1/flut200/reports/detail';
  static const String reportCommentsPath = '/api/v1/flut200/reports/comments';
  static const String attendancePath = '/api/v1/flut200/attendance';
  static const String mealsPath = '/api/v1/flut200/meals';
  static const String schedulePath = '/api/v1/flut200/schedule';
  static const String galleryPath = '/api/v1/flut200/gallery';
  static const String pickupPath = '/api/v1/flut200/pickup';
  static const String staffProfilePath = '/api/v1/flut300/profile';
  static const String staffPersonalProfilePath = '/api/v1/flut300/profile/personal';
  static const String staffProfilePhotoPath = '/api/v1/flut300/profile/photo';
  static const String directorStaffPersonalPath = '/api/v1/flut300/director/staff/personal';
  static const String staffHomePath = '/api/v1/flut300/home';
  static const String staffClassPath = '/api/v1/flut300/class';
  static const String staffReportsPath = '/api/v1/flut300/reports';
  static const String staffReportDetailPath = '/api/v1/flut300/reports/detail';
  static const String staffReportCommentsPath = '/api/v1/flut300/reports/comments';
  static const String staffDailyReportTemplatePath =
      '/api/v1/flut300/reports/daily-template';
  static const String staffReportPhotosPath = '/api/v1/flut300/reports/photos';
  static const String staffMessagesPath = '/api/v1/flut300/messages';
  static const String directorDashboardPath = '/api/v1/flut300/director/dashboard';
  static const String directorStaffPath = '/api/v1/flut300/director/staff';
  static const String directorChildrenPath = '/api/v1/flut300/director/children';
  static const String directorGroupsPath = '/api/v1/flut300/director/groups';
  static const String directorGroupDetailPath = '/api/v1/flut300/director/groups/detail';
  static const String directorAnnouncementsPath = '/api/v1/flut300/director/announcements';
  static const String publicSplashPath = '/api/v1/flut100/splash';
  static const String parentSplashPath = '/api/v1/flut200/splash';
  static const String staffSplashPath = '/api/v1/flut300/splash';
  static const String directorSplashPath = '/api/v1/flut300/director/splash';
  static const String staffChildPath = '/api/v1/flut300/child';
}
