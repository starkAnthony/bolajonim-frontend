import 'announcement_model.dart';
import 'child_model.dart';
import 'today_report_summary.dart';
import '../utils/html_text.dart';

class HomeModel {
  final ChildModel? child;
  final String? todayReportPreview;
  final TodayReportSummary? todayReport;
  final AnnouncementModel? latestAnnouncement;
  final AnnouncementModel? upcomingEvent;

  const HomeModel({
    this.child,
    this.todayReportPreview,
    this.todayReport,
    this.latestAnnouncement,
    this.upcomingEvent,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      child: json['child'] == null
          ? null
          : ChildModel.fromJson(json['child'] as Map<String, dynamic>),
      todayReportPreview: decodeHtmlText(json['todayReportPreview']?.toString()),
      todayReport: json['todayReport'] == null
          ? null
          : TodayReportSummary.fromJson(
              json['todayReport'] as Map<String, dynamic>,
            ),
      latestAnnouncement: json['latestAnnouncement'] == null
          ? null
          : AnnouncementModel.fromJson(
              json['latestAnnouncement'] as Map<String, dynamic>,
            ),
      upcomingEvent: json['upcomingEvent'] == null
          ? null
          : AnnouncementModel.fromJson(
              json['upcomingEvent'] as Map<String, dynamic>,
            ),
    );
  }
}
