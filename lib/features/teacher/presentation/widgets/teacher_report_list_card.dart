import 'package:flutter/material.dart';

import '../../../../core/models/teacher_report_model.dart';
import '../../../../core/services/teacher_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/report_format_utils.dart';
import '../../../../core/widgets/network_image_frame.dart';
import '../../../../core/widgets/report_status_banner.dart';

class TeacherReportListCard extends StatelessWidget {
  final TeacherReportModel report;
  final VoidCallback onTap;

  const TeacherReportListCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  String get _typeLabel => report.reportType == 'health'
      ? 'Sog\'liq ko\'rik'
      : 'Kunlik hisobot';

  @override
  Widget build(BuildContext context) {
    final coverUrl = TeacherApi.resolvePhotoUrl(report.coverPhotoUrl);
    final preview = (report.previewText ?? '').trim();
    final created = ReportFormatUtils.formatTimestamp(report.createdAt);

    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    report.reportType == 'health'
                        ? Icons.monitor_heart_outlined
                        : Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.childName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          ReportStatusChip(
                            reportStatus: report.reportStatus,
                            useYn: report.useYn,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _typeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (preview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          preview,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${ReportFormatUtils.formatReportDate(report.reportDate)}${created.isEmpty ? '' : ' · $created'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (coverUrl != null && coverUrl.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  NetworkImageFrame(
                    imageUrl: coverUrl,
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.circular(14),
                    fit: BoxFit.cover,
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }
}