import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/models/country_phone_code.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/api_error_utils.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/international_phone_field.dart';
import '../../../core/widgets/shake_widget.dart';
import '../../../core/widgets/validated_text_field.dart';
import 'login_screen.dart';

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
  int _shakeTrigger = 0;
  String _selectedRelation = 'Ona';
  CountryPhoneCode _selectedCountry = CountryPhoneCode.uzbekistan;

  final Set<String> _fieldErrors = {};
  final Map<String, String> _customFieldErrors = {};

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  static String get _signUpEndpoint =>
      '${ApiConfig.baseUrl}${ApiConfig.parentSignUpPath}';

  @override
  void dispose() {
    _userIdController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    final hadError = _fieldErrors.remove(field);
    final hadCustom = _customFieldErrors.remove(field) != null;
    if (hadError || hadCustom) {
      setState(() {});
    }
  }

  Future<bool> _checkDuplicatesBeforeSubmit() async {
    final userId = _userIdController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    final checks = <Future<MapEntry<String, String>?>>[];

    checks.add(() async {
      if (await BolajonimApi.isUserIdTaken(userId)) {
        return const MapEntry('userId', 'Bu foydalanuvchi ID band.');
      }
      return null;
    }());

    if (phone.isNotEmpty &&
        PhoneUtils.isValidLocalNumber(_selectedCountry, phone)) {
      final international =
          PhoneUtils.toInternational(_selectedCountry, phone);
      checks.add(() async {
        if (await BolajonimApi.isPhoneTaken(international)) {
          return const MapEntry('phone', 'Bu telefon raqam band.');
        }
        return null;
      }());
    }

    if (email.isNotEmpty && _isValidEmail(email)) {
      checks.add(() async {
        if (await BolajonimApi.isEmailTaken(email)) {
          return const MapEntry('email', 'Bu email band.');
        }
        return null;
      }());
    }

    final duplicates =
        (await Future.wait(checks)).whereType<MapEntry<String, String>>();

    if (duplicates.isEmpty) {
      return true;
    }

    setState(() {
      _customFieldErrors.clear();
      for (final entry in duplicates) {
        _fieldErrors.add(entry.key);
        _customFieldErrors[entry.key] = entry.value;
      }
      _shakeTrigger++;
    });

    _showMessage('Bu ID, telefon yoki email allaqachon ro‘yxatdan o‘tgan.');
    return false;
  }

  void _applySignupFailureMessage(String message) {
    final localized = ApiErrorUtils.localize(message);

    String? field;
    if (message.contains('User ID is already')) {
      field = 'userId';
    } else if (message.contains('Email is already')) {
      field = 'email';
    } else if (message.contains('Phone number is already')) {
      field = 'phone';
    }

    if (field != null) {
      setState(() {
        _fieldErrors.add(field!);
        _customFieldErrors[field] = localized;
        _shakeTrigger++;
      });
    }

    _showMessage(localized);
  }

  bool _validateForm() {
    final errors = <String>{};

    final userId = _userIdController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (userId.isEmpty) {
      errors.add('userId');
    } else if (!_isValidUserId(userId)) {
      errors.add('userId');
    }

    if (fullName.isEmpty) errors.add('fullName');

    final hasPhone = phone.isNotEmpty;
    final hasEmail = email.isNotEmpty;

    if (!hasPhone && !hasEmail) {
      errors.add('phone');
      errors.add('email');
    }

    if (hasPhone && !PhoneUtils.isValidLocalNumber(_selectedCountry, phone)) {
      errors.add('phone');
    }

    if (hasEmail && !_isValidEmail(email)) {
      errors.add('email');
    }

    if (password.isEmpty) {
      errors.add('password');
    } else if (password.length < 6) {
      errors.add('password');
    }

    if (confirmPassword.isEmpty) {
      errors.add('confirmPassword');
    } else if (password != confirmPassword) {
      errors.add('confirmPassword');
    }

    if (!_agree) errors.add('agree');

    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) errors.add('inviteCode');

    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
      if (errors.isNotEmpty) _shakeTrigger++;
    });

    if (errors.isNotEmpty) {
      _showMessage('Iltimos, qizil belgilangan maydonlarni to‘ldiring.');
      return false;
    }

    return true;
  }

  Future<void> _handleContinue() async {
    if (_isLoading || !_validateForm()) return;

    final userId = _userIdController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final inviteCode = _inviteCodeController.text.trim();

    setState(() => _isLoading = true);

    try {
      if (!await _checkDuplicatesBeforeSubmit()) {
        return;
      }

      final requestBody = <String, dynamic>{
        'userId': userId,
        'userNm': fullName,
        'userPwd': password,
        'relation': _selectedRelation,
        'agreeYn': 'Y',
        'inviteCode': inviteCode,
      };

      if (phone.isNotEmpty) {
        requestBody['userHpTelNo'] = PhoneUtils.toInternational(
          _selectedCountry,
          phone,
        );
      }

      if (email.isNotEmpty) {
        requestBody['emlAdr'] = email.toLowerCase();
      }

      final response = await http.post(
        Uri.parse(_signUpEndpoint),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode(requestBody)),
      );

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
          : {};

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = data['result'] as Map<String, dynamic>?;
        final bool success = result?['success'] == true;

        if (success) {
          await SessionService.savePendingInviteCode(inviteCode);
          await SessionService.savePendingRelation(_selectedRelation);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(
                successMessage:
                    'Akkaunt yaratildi. Endi kiring va bolangizni bog‘chadagi ro‘yxatga bog‘lang.',
              ),
            ),
          );
          return;
        }

        _applySignupFailureMessage(
          result?['message']?.toString() ??
              ApiErrorUtils.fromResponseBody(data),
        );
      } else {
        _showMessage(ApiErrorUtils.fromResponseBody(data));
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Tarmoq xatosi: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _isValidUserId(String userId) {
    return RegExp(r'^[a-zA-Z0-9_]{4,20}$').hasMatch(userId);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _errorText(String field) {
    if (!_fieldErrors.contains(field)) return null;

    final custom = _customFieldErrors[field];
    if (custom != null) return custom;

    return switch (field) {
      'userId' => 'ID 4-20 belgi, faqat harf, raqam va "_"',
      'fullName' => 'To‘liq ism kiritilishi shart',
      'phone' => 'Telefon raqam noto‘g‘ri yoki kiritilmagan',
      'email' => 'Email noto‘g‘ri yoki kiritilmagan',
      'password' => 'Parol kamida 6 belgidan iborat bo‘lishi kerak',
      'confirmPassword' => 'Parollar mos emas',
      'agree' => 'Davom etish uchun rozilik kerak',
      'inviteCode' => 'Bog‘cha taklif kodi kiritilishi shart',
      _ => 'Maydon to‘ldirilishi shart',
    };
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
                      _buildLabel('ID *'),
                      const SizedBox(height: 8),
                      ValidatedTextField(
                        controller: _userIdController,
                        hint: 'Login ID kiriting',
                        hasError: _fieldErrors.contains('userId'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('userId'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('userId'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('To‘liq ism *'),
                      const SizedBox(height: 8),
                      ValidatedTextField(
                        controller: _fullNameController,
                        hint: 'Ism va familiyangizni kiriting',
                        hasError: _fieldErrors.contains('fullName'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('fullName'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('fullName'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Telefon raqam'),
                      const SizedBox(height: 4),
                      const Text(
                        'Telefon yoki emaildan kamida bittasi kerak',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InternationalPhoneField(
                        controller: _phoneController,
                        selectedCountry: _selectedCountry,
                        onCountryChanged: (country) {
                          setState(() => _selectedCountry = country);
                          _clearFieldError('phone');
                        },
                        hasError: _fieldErrors.contains('phone'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('phone'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('phone'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Email manzil'),
                      const SizedBox(height: 8),
                      ValidatedTextField(
                        controller: _emailController,
                        hint: 'example@email.com (ixtiyoriy)',
                        keyboardType: TextInputType.emailAddress,
                        hasError: _fieldErrors.contains('email'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('email'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('email'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Farzandga aloqangiz'),
                      const SizedBox(height: 8),
                      _buildRelationSelector(),
                      const SizedBox(height: 16),
                      _buildLabel('Bog‘cha taklif kodi *'),
                      const SizedBox(height: 8),
                      ValidatedTextField(
                        controller: _inviteCodeController,
                        hint: 'Direktordan olingan kod',
                        hasError: _fieldErrors.contains('inviteCode'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('inviteCode'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('inviteCode'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O‘qituvchi kabi, ota-ona ham bog‘cha taklif kodi bilan bog‘lanadi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Parol *'),
                      const SizedBox(height: 8),
                      ValidatedTextField(
                        controller: _passwordController,
                        hint: 'Parol yarating',
                        obscureText: _hidePassword,
                        hasError: _fieldErrors.contains('password'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('password'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('password'),
                        suffix: IconButton(
                          onPressed: () {
                            setState(() => _hidePassword = !_hidePassword);
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
                      _buildLabel('Parolni tasdiqlang *'),
                      const SizedBox(height: 8),
                      ValidatedTextField(
                        controller: _confirmPasswordController,
                        hint: 'Parolni qayta kiriting',
                        obscureText: _hideConfirmPassword,
                        hasError: _fieldErrors.contains('confirmPassword'),
                        shakeTrigger: _shakeTrigger,
                        errorText: _errorText('confirmPassword'),
                        enabled: !_isLoading,
                        onChanged: () => _clearFieldError('confirmPassword'),
                        suffix: IconButton(
                          onPressed: () {
                            setState(
                              () => _hideConfirmPassword = !_hideConfirmPassword,
                            );
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
                      ShakeWidget(
                        shakeTrigger: _shakeTrigger,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _agree = !_agree;
                                        _clearFieldError('agree');
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _fieldErrors.contains('agree')
                                        ? const Color(0xFFE53935)
                                        : (_agree
                                            ? AppColors.primary
                                            : const Color(0xFFBFC5CD)),
                                    width: _fieldErrors.contains('agree') ? 2 : 1.5,
                                  ),
                                  color: _agree
                                      ? AppColors.primary
                                      : (_fieldErrors.contains('agree')
                                          ? const Color(0xFFFFF5F5)
                                          : Colors.white),
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
                      ),
                      if (_fieldErrors.contains('agree')) ...[
                        const SizedBox(height: 6),
                        Text(
                          _errorText('agree')!,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
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
              onTap: () => setState(() => _selectedRelation = relation),
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
}
