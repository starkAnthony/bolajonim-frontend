import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/report_format_utils.dart';

class ReportStatusBanner extends StatelessWidget {
  final String? reportStatus;
  final String? useYn;
  final String? updatedAt;

  const ReportStatusBanner({
    super.key,
    this.reportStatus,
    this.useYn,
    this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final deleted = ReportFormatUtils.isDeleted(reportStatus, useYn: useYn);
    final edited = ReportFormatUtils.isEdited(reportStatus);

    if (!deleted && !edited) return const SizedBox.shrink();

    final Color bg;
    final Color fg;
    final IconData icon;
    final String message;

    if (deleted) {
      bg = const Color(0xFFFFF1F1);
      fg = const Color(0xFFB42318);
      icon = Icons.delete_outline_rounded;
      message =
          'Bu hisobot bog‘cha tomonidan o‘chirildi. Eski ma’lumot endi amalda emas.';
    } else {
      bg = const Color(0xFFEFF8FF);
      fg = const Color(0xFF175CD3);
      icon = Icons.edit_note_rounded;
      final when = ReportFormatUtils.formatTimestamp(updatedAt);
      message = when.isEmpty
          ? 'Bu hisobot direktor tomonidan yangilandi.'
          : 'Bu hisobot direktor tomonidan yangilandi ($when).';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportStatusChip extends StatelessWidget {
  final String? reportStatus;
  final String? useYn;

  const ReportStatusChip({
    super.key,
    this.reportStatus,
    this.useYn,
  });

  @override
  Widget build(BuildContext context) {
    final label = ReportFormatUtils.statusLabel(reportStatus, useYn: useYn);
    if (label.isEmpty) return const SizedBox.shrink();

    final deleted = ReportFormatUtils.isDeleted(reportStatus, useYn: useYn);
    final color = deleted ? const Color(0xFFB42318) : const Color(0xFF175CD3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
