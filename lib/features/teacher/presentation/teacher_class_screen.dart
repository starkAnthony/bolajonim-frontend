import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherClassScreen extends StatelessWidget {
  const TeacherClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      {'name': 'Salih', 'status': 'Present'},
      {'name': 'Amina', 'status': 'Present'},
      {'name': 'Yusuf', 'status': 'Absent'},
      {'name': 'Maryam', 'status': 'Present'},
      {'name': 'Ibrohim', 'status': 'Present'},
      {'name': 'Zara', 'status': 'Pending'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class', style: AppTextStyles.headlineMedium),
                  SizedBox(height: 6),
                  Text(
                    'Manage children in your classroom.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search child...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = students[index];
                  return _StudentTile(
                    name: item['name']!,
                    status: item['status']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final String name;
  final String status;

  const _StudentTile({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeBg;

    switch (status) {
      case 'Present':
        badgeColor = const Color(0xFF198754);
        badgeBg = const Color(0xFFE7F7EE);
        break;
      case 'Absent':
        badgeColor = Colors.red;
        badgeBg = const Color(0xFFFFEBEE);
        break;
      default:
        badgeColor = Colors.orange;
        badgeBg = const Color(0xFFFFF4E5);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFEFF8F6),
            child: Icon(Icons.child_care_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
