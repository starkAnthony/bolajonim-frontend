import 'package:flutter/material.dart';

import '../models/report_section_model.dart';
import '../theme/app_colors.dart';

class DailyReportSummaryCard extends StatelessWidget {
  final List<ReportTableRowModel> rows;
  final String? title;

  const DailyReportSummaryCard({
    super.key,
    required this.rows,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'Kunlik ko‘rsatkichlar',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SummaryRow(row: row),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final ReportTableRowModel row;

  const _SummaryRow({required this.row});

  IconData get _icon {
    final key = row.fieldKey ?? '';
    switch (key) {
      case 'mood':
        return Icons.sentiment_satisfied_alt_outlined;
      case 'health':
        return Icons.favorite_border_rounded;
      case 'temperature':
        return Icons.thermostat_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      case 'sleep_hours':
        return Icons.bedtime_outlined;
      case 'bowel':
        return Icons.water_drop_outlined;
      case 'sleep_time':
        return Icons.schedule_outlined;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              row.value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
