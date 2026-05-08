import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../child/child_setup_screen.dart';

class ParentSignUpScreen extends StatefulWidget {
  const ParentSignUpScreen({super.key});

  @override
  State<ParentSignUpScreen> createState() => _ParentSignUpScreenState();
}

class _ParentSignUpScreenState extends State<ParentSignUpScreen> {
  bool _agree = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  String _selectedRelation = 'Ona';

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //static const String _baseUrl = 'http://192.168.1.59:8081';
  static const String _baseUrl =
      'https://ampland-kent-lit-embedded.trycloudflare.com';

  static const String _signUpEndpoint =
      '$_baseUrl/api/v1/flut100/parent/signUp';

  @override
  void dispose() {
    _userIdController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final userId = _userIdController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (userId.isEmpty ||
        fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Iltimos, barcha maydonlarni to‘ldiring.');
      return;
    }

    if (!_isValidUserId(userId)) {
      _showMessage(
        'ID 4-20 ta belgi bo‘lsin. Faqat harf, raqam va "_" ishlating.',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Email manzil noto‘g‘ri.');
      return;
    }

    if (!_isValidPhone(phone)) {
      _showMessage('Telefon raqam noto‘g‘ri.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Parol kamida 6 ta belgidan iborat bo‘lishi kerak.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Parollar mos emas.');
      return;
    }

    if (!_agree) {
      _showMessage('Davom etish uchun rozilikni belgilang.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestBody = {
        'userId': userId,
        'userNm': fullName,
        'userHpTelNo': _normalizePhone(phone),
        'emlAdr': email,
        'userPwd': password,
        'roleType': 'PARENT',
        'relation': _selectedRelation,
        'agreeYn': 'Y',
      };

      final response = await http.post(
        Uri.parse(_signUpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : {};

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final bool success =
            data['success'] == true ||
            data['result'] == 1 ||
            data['resultCode'] == 200;

        if (success) {
          _showMessage('Akkaunt muvaffaqiyatli yaratildi.');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildSetupScreen(
                parentName: fullName,
                relation: _selectedRelation,
                phone: _normalizePhone(phone),
                email: email,
              ),
            ),
          );
          return;
        }

        final String message =
            data['message']?.toString() ??
            data['resultUserMessage']?.toString() ??
            'Ro‘yxatdan o‘tishda xatolik yuz berdi.';
        _showMessage(message);
      } else {
        final String message =
            data['message']?.toString() ??
            data['resultUserMessage']?.toString() ??
            'Server bilan ulanishda xatolik yuz berdi.';
        _showMessage(message);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Tarmoq xatosi: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final normalized = _normalizePhone(phone);
    return normalized.length >= 9 && normalized.length <= 15;
  }

  bool _isValidUserId(String userId) {
    final idRegex = RegExp(r'^[a-zA-Z0-9_]{4,20}$');
    return idRegex.hasMatch(userId);
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Ota-ona akkaunti',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Farzandingiz uchun akkaunt yarating',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLabel('ID'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Login ID kiriting',
                        controller: _userIdController,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('To‘liq ism'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Ism va familiyangizni kiriting',
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Telefon raqam'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: '+998 90 000 00 00',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Email manzil'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'example@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Farzandga aloqangiz'),
                      const SizedBox(height: 8),
                      _buildRelationSelector(),
                      const SizedBox(height: 16),
                      _buildLabel('Parol'),
                      const SizedBox(height: 8),
                      _buildInput(
                        hint: 'Parol yarating',
                        controller: _passwordController,
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
                        controller: _confirmPasswordController,
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
                            onTap: _isLoading
                                ? null
                                : () {
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
                  onPressed: (_agree && !_isLoading) ? _handleContinue : null,
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
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Davom etish',
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

  Widget _buildRelationSelector() {
    final relations = ['Ona', 'Ota', 'Vasiy'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: relations.map((relation) {
          final isSelected = _selectedRelation == relation;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRelation = relation;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  relation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
    );
  }
}
