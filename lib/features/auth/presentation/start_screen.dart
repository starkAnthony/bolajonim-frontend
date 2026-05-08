import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/typewriter_text.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _showTitle = false;
  bool _showSubtitle = false;
  bool _showButtons = false;
  bool _showFooter = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showTitle = true);
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showSubtitle = true);
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showButtons = true);
    });

    Future.delayed(const Duration(milliseconds: 1250), () {
      if (mounted) setState(() => _showFooter = true);
    });
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                offset: _showTitle ? Offset.zero : const Offset(0, 1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _showTitle ? 1 : 0,
                  child: const Text(
                    'Bolajonim',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLarge,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                offset: _showSubtitle ? Offset.zero : const Offset(0, 1.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showSubtitle ? 1 : 0,
                  child: _showSubtitle
                      ? const TypewriterText(
                          text:
                              'Farzandingizning bog‘chadagi kunini\nmehr bilan kuzating.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                          speed: Duration(milliseconds: 55),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              const Spacer(),

              Column(
                children: [
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    offset: _showButtons ? Offset.zero : const Offset(-1.2, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 650),
                      opacity: _showButtons ? 1 : 0,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _goToLogin,
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
                            'Kirish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  AnimatedSlide(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    offset: _showButtons ? Offset.zero : const Offset(1.2, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 650),
                      opacity: _showButtons ? 1 : 0,
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _goToSignUp,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.4,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Ro‘yxatdan o‘tish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _showFooter ? 1 : 0,
                child: const Text(
                  'Bog‘cha va ota-onalar uchun qulay aloqa',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
