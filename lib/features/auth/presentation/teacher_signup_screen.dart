import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherSignUpScreen extends StatelessWidget {
  const TeacherSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 22,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0.66,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE6EAF0),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'O‘qituvchi akkaunti',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Teacher sign up form next stepda qilamiz',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}