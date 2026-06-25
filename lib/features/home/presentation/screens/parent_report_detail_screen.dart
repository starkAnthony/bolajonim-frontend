import 'package:flutter/material.dart';

import '/../../core/models/report_detail_model.dart';
import '/../../core/models/report_photo_model.dart';
import '/../../core/models/report_section_model.dart';
import '/../../core/services/bolajonim_api.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';
import '/../../core/utils/report_format_utils.dart';
import '/../../core/widgets/daily_report_fields_form.dart';
import '/../../core/widgets/daily_report_summary_card.dart';
import '/../../core/widgets/network_image_frame.dart';
import '/../../core/widgets/report_photo_viewer_screen.dart';
import '/../../core/widgets/report_status_banner.dart';
import '/../../core/widgets/report_comments_section.dart';
import '/../../core/widgets/report_writer_header.dart';

class ParentReportDetailScreen extends StatefulWidget {
  final int reportNo;
  final String childNo;

  const ParentReportDetailScreen({
    super.key,
    required this.reportNo,
    required this.childNo,
  });

  @override
  State<ParentReportDetailScreen> createState() =>
      _ParentReportDetailScreenState();
}

class _ParentReportDetailScreenState extends State<ParentReportDetailScreen> {
  late Future<ReportDetailModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = BolajonimApi.getReportDetail(
      reportNo: widget.reportNo,
      childNo: widget.childNo,
    );
  }

  String _formatDate(String? raw) => ReportFormatUtils.formatReportDate(raw);

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
      ),
      body: FutureBuilder<ReportDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Yuklab bo‘lmadi: ${snapshot.error}'),
              ),
            );
          }

          final detail = snapshot.data!;
          final created = ReportFormatUtils.formatTimestamp(detail.createdAt);
          final summaryRows = extractDailySummaryRows(detail.sections);
          final otherSections = detail.sections
              .where((s) => s.sectionType != 'table')
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        detail.typeLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatDate(detail.reportDate),
                      style: AppTextStyles.bodySmall,
                    ),
                    if (created.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Yaratilgan: $created',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                    if (!detail.isDeleted &&
                        detail.previewText?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Text(detail.previewText!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (!detail.isDeleted) ...[
                if (summaryRows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DailyReportSummaryCard(rows: summaryRows),
                ],
                const SizedBox(height: 12),
                if (detail.photos.isNotEmpty) ...[
                  _PhotoGrid(photos: detail.photos),
                  const SizedBox(height: 12),
                ],
                ...otherSections.map(_SectionCard.new),
                const SizedBox(height: 12),
                ReportCommentsSection(
                  reportNo: widget.reportNo,
                  enabled: !detail.isDeleted,
                  loadComments: () => BolajonimApi.getReportComments(
                    reportNo: widget.reportNo,
                    childNo: widget.childNo,
                  ),
                  postComment: ({
                    required String commentText,
                    int? parentCommentNo,
                  }) =>
                      BolajonimApi.postReportComment(
                    reportNo: widget.reportNo,
                    childNo: widget.childNo,
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

class _PhotoGrid extends StatelessWidget {
  final List<ReportPhotoModel> photos;

  const _PhotoGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rasmlar',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final photo = photos[index];
              final url = BolajonimApi.resolveMediaUrl(photo.imageUrl);
              return NetworkImageFrame(
                imageUrl: url,
                borderRadius: BorderRadius.circular(12),
                onTap: url == null
                    ? null
                    : () {
                        final items = photos
                            .map((item) {
                              final resolved =
                                  BolajonimApi.resolveMediaUrl(item.imageUrl);
                              if (resolved == null) return null;
                              return ReportPhotoViewerItem(
                                url: resolved,
                                fileName:
                                    'hisobot-${item.reportNo}-${item.photoNo}.jpg',
                                caption: item.caption,
                              );
                            })
                            .whereType<ReportPhotoViewerItem>()
                            .toList();

                        if (items.isEmpty) return;

                        final openIndex = items.indexWhere(
                          (item) => item.url == url,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportPhotoViewerScreen(
                              photos: items,
                              initialIndex: openIndex >= 0 ? openIndex : 0,
                            ),
                          ),
                        );
                      },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ReportSectionModel section;

  const _SectionCard(this.section);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title?.isNotEmpty == true) ...[
            Text(
              section.title!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (section.sectionType == 'table')
            ...section.rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.label,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (section.bodyText?.isNotEmpty == true)
            Text(section.bodyText!, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
