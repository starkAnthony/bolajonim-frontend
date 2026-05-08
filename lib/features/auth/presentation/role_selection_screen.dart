import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'director_signup_screen.dart';
import 'parent_signup_screen.dart';
import 'teacher_signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'parent';

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
                  value: 0.33,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE6EAF0),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Assalomu alaykum!', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 12),
              const Text(
                'Ilovadan kim sifatida foydalanasiz?',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              _RoleCard(
                title: 'Ota-ona sifatida',
                isSelected: selectedRole == 'parent',
                onTap: () => setState(() => selectedRole = 'parent'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'O‘qituvchi sifatida',
                isSelected: selectedRole == 'teacher',
                onTap: () => setState(() => selectedRole = 'teacher'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Direktor sifatida',
                isSelected: selectedRole == 'director',
                onTap: () => setState(() => selectedRole = 'director'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Widget nextScreen;

                    if (selectedRole == 'parent') {
                      nextScreen = const ParentSignUpScreen();
                    } else if (selectedRole == 'teacher') {
                      nextScreen = const TeacherSignUpScreen();
                    } else {
                      nextScreen = const DirectorSignUpScreen();
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => nextScreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Keyingi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        isSelected ? AppColors.primary : const Color(0xFFD9DDE3);
    final Color fillColor =
        isSelected ? AppColors.primary.withOpacity(0.12) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFBFC5CD),
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}