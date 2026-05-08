import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherReportsScreen extends StatelessWidget {
  const TeacherReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Daily attendance report',
      'Meal consumption notes',
      'Nap / sleep tracking',
      'Behavior / activity summary',
      'Parent handoff notes',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        label: const Text('New report'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
          children: [
            const Text('Reports', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            const Text(
              'Create and manage daily teacher records.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 18),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
