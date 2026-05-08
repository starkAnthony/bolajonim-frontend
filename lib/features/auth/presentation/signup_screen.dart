import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agree = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

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
                'Ro‘yxatdan o‘tish',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Boshlash uchun akkaunt yarating',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLabel('Ism'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Ismingizni kiriting',
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Email manzil'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'name@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Telefon raqam'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: '+998 90 000 00 00',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Parol'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Parol yarating',
                        obscureText: _hidePassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Parolni tasdiqlang'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Parolni qayta kiriting',
                        obscureText: _hideConfirmPassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword = !_hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agree = !_agree;
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agree
                                      ? AppColors.primary
                                      : const Color(0xFFBFC5CD),
                                  width: 1.5,
                                ),
                                color: _agree
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                              child: _agree
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Men ',
                                style: AppTextStyles.bodySmall,
                                children: [
                                  TextSpan(
                                    text: 'Shartlar va qoidalar',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ' hamda '),
                                  TextSpan(
                                    text: 'Maxfiylik siyosati',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' bilan tanishdim va roziman.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agree ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBFE7E2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Akkaunt yaratish',
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

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
      ),
    );
  }
}