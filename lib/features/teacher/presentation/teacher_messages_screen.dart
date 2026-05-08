import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherMessagesScreen extends StatelessWidget {
  const TeacherMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {'name': 'Salih’s Parent', 'message': 'He may arrive a bit late today.'},
      {'name': 'Amina’s Parent', 'message': 'Please check her lunch allergy.'},
      {'name': 'Yusuf’s Parent', 'message': 'Thank you for the update.'},
      {'name': 'Admin Office', 'message': 'Submit attendance before 10 AM.'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text('Messages', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            const Text(
              'Communicate with parents and staff.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ...chats.map(
              (chat) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
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
                        child: Icon(Icons.person_outline_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat['name']!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat['message']!,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
