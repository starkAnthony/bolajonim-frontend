import 'package:flutter/material.dart';

import '../../../core/models/report_detail_model.dart';
import '../../../core/models/report_photo_model.dart';
import '../../../core/models/report_section_model.dart';
import '../../../core/models/teacher_class_child_model.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/report_format_utils.dart';
import '../../../core/widgets/daily_report_fields_form.dart';
import '../../../core/widgets/daily_report_summary_card.dart';
import '../../../core/widgets/network_image_frame.dart';
import '../../../core/widgets/report_photo_viewer_screen.dart';
import '../../../core/widgets/report_status_banner.dart';
import '../../../core/widgets/report_comments_section.dart';
import '../../../core/widgets/report_writer_header.dart';
import '../../../core/services/bolajonim_api.dart';
import 'widgets/teacher_create_report_dialog.dart';

class TeacherReportDetailScreen extends StatefulWidget {
  final int reportNo;
  final String childName;
  final bool isDirector;

  const TeacherReportDetailScreen({
    super.key,
    required this.reportNo,
    required this.childName,
    required this.isDirector,
  });

  @override
  State<TeacherReportDetailScreen> createState() =>
      _TeacherReportDetailScreenState();
}

class _TeacherReportDetailScreenState extends State<TeacherReportDetailScreen> {
  late Future<ReportDetailModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = TeacherApi.getReportDetail(widget.reportNo);
  }

  void _reload() {
    setState(() {
      _detailFuture = TeacherApi.getReportDetail(widget.reportNo);
    });
  }

  Future<void> _edit(ReportDetailModel detail) async {
    final children = [
      TeacherClassChildModel(
        childNo: detail.childNo,
        childName: widget.childName,
        todayStatus: 'pending',
      ),
    ];
    final updated = await TeacherCreateReportDialog.open(
      context,
      children: children,
      existingDetail: detail,
    );
    if (updated == true) _reload();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hisobotni o‘chirish'),
        content: const Text(
          'Hisobot ota-onalar uchun o‘chirilgan deb ko‘rinadi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              foregroundColor: Colors.white,
            ),
            child: const Text('O‘chirish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await TeacherApi.deleteReport(widget.reportNo);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O‘chirib bo‘lmadi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Hisobot tafsiloti',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (widget.isDirector)
            PopupMenuButton<String>(
              onSelected: (value) async {
                final detail = await _detailFuture;
                if (!mounted) return;
                if (value == 'edit') {
                  await _edit(detail);
                } else if (value == 'delete') {
                  await _delete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                PopupMenuItem(value: 'delete', child: Text('O‘chirish')),
              ],
            ),
        ],
      ),
      body: FutureBuilder<ReportDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Yuklab bo‘lmadi: ${snapshot.error}'));
          }

          final detail = snapshot.data!;
          final created = ReportFormatUtils.formatTimestamp(detail.createdAt);
          final summaryRows = extractDailySummaryRows(detail.sections);
          final otherSections = detail.sections
              .where((s) => s.sectionType != 'table')
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              ReportStatusBanner(
                reportStatus: detail.reportStatus,
                useYn: detail.useYn,
                updatedAt: detail.updatedAt,
              ),
              if (detail.isDeleted) const SizedBox(height: 12),
              if (!detail.isDeleted &&
                  (detail.writerName?.isNotEmpty ?? false)) ...[
                ReportWriterHeader(
                  writerName: detail.writerName,
                  writerRole: detail.writerRole,
                  writerPhotoUrl: BolajonimApi.resolveMediaUrl(
                    detail.writerPhotoUrl,
                  ),
                  reportDate: detail.reportDate,
                  createdAt: detail.createdAt,
                  weather: detail.weather,
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.childName, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 6),
                    Text(detail.typeLabel, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      ReportFormatUtils.formatReportDate(detail.reportDate),
                      style: AppTextStyles.bodySmall,
                    ),
                    if (created.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Yaratilgan: $created',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (!detail.isDeleted) ...[
                const SizedBox(height: 12),
                if ((detail.previewText ?? '').isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      detail.previewText!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                if (summaryRows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DailyReportSummaryCard(rows: summaryRows),
                ],
                ...otherSections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _SectionCard(section: section),
                  ),
                ),
                if (detail.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _PhotoGrid(photos: detail.photos),
                ],
                const SizedBox(height: 12),
                ReportCommentsSection(
                  reportNo: widget.reportNo,
                  enabled: !detail.isDeleted,
                  loadComments: () =>
                      TeacherApi.getReportComments(widget.reportNo),
                  postComment: ({
                    required String commentText,
                    int? parentCommentNo,
                  }) =>
                      TeacherApi.postReportComment(
                    reportNo: widget.reportNo,
                    commentText: commentText,
                    parentCommentNo: parentCommentNo,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ReportSectionModel section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((section.title ?? '').isNotEmpty)
            Text(section.title!, style: AppTextStyles.titleLarge),
          if (section.rows.isNotEmpty)
            ...section.rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(row.label)),
                    Text(
                      row.value,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          if ((section.bodyText ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(section.bodyText!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<ReportPhotoModel> photos;

  const _PhotoGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        final url = TeacherApi.resolvePhotoUrl(photo.imageUrl);
        if (url == null) return const SizedBox.shrink();
        return NetworkImageFrame(
          imageUrl: url,
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final items = photos
                .map((p) {
                  final resolved = TeacherApi.resolvePhotoUrl(p.imageUrl);
                  if (resolved == null) return null;
                  return ReportPhotoViewerItem(
                    url: resolved,
                    fileName: 'hisobot-${p.reportNo}-${p.photoNo}.jpg',
                    caption: p.caption,
                  );
                })
                .whereType<ReportPhotoViewerItem>()
                .toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportPhotoViewerScreen(
                  photos: items,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
