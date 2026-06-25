import 'package:flutter/material.dart';

import '../../../core/models/country_phone_code.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/api_error_utils.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/animated_segment_switcher.dart';
import '../../../core/widgets/international_phone_field.dart';
import '../../../core/widgets/validated_text_field.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const double _fieldHeight = 64;
  static const double _fieldRadius = 20;

  bool _usePhoneRecovery = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _shakeTrigger = 0;
  CountryPhoneCode _selectedCountry = CountryPhoneCode.uzbekistan;

  final Set<String> _fieldErrors = {};

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.remove(field)) {
      setState(() {});
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _validateForm() {
    final errors = <String>{};

    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (_usePhoneRecovery) {
      if (phone.isEmpty ||
          !PhoneUtils.isValidLocalNumber(_selectedCountry, phone)) {
        errors.add('phone');
      }
    } else {
      if (email.isEmpty || !_isValidEmail(email)) {
        errors.add('email');
      }
    }

    if (password.isEmpty || password.length < 6) {
      errors.add('password');
    }

    if (confirmPassword.isEmpty || password != confirmPassword) {
      errors.add('confirmPassword');
    }

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

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    if (_isLoading || !_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();

      await BolajonimApi.resetPassword(
        newPassword: _passwordController.text.trim(),
        phone: _usePhoneRecovery
            ? PhoneUtils.toInternational(_selectedCountry, phone)
            : null,
        email: _usePhoneRecovery ? null : email.toLowerCase(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            successMessage:
                'Parol yangilandi. Endi telefon, email yoki ID va yangi parol bilan kiring.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      _showMessage(ApiErrorUtils.localize(message));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 28),
                const Text(
                  'Parolni tiklash',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ro‘yxatdan o‘tgan telefon yoki emailingizni kiriting va yangi parol o‘rnating',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                _buildFutureOtpNotice(),
                const SizedBox(height: 24),
                _buildRecoverySwitcher(),
                const SizedBox(height: 28),
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  child: SegmentContentTransition(
                    child: _usePhoneRecovery
                        ? _buildPhoneFields(key: const ValueKey('phone'))
                        : _buildEmailFields(key: const ValueKey('email')),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yangi parol',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ValidatedTextField(
                  controller: _passwordController,
                  hint: 'Kamida 6 belgi',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  hasError: _fieldErrors.contains('password'),
                  shakeTrigger: _shakeTrigger,
                  errorText: _fieldErrors.contains('password')
                      ? 'Parol kamida 6 belgidan iborat bo‘lishi kerak'
                      : null,
                  enabled: !_isLoading,
                  onChanged: () => _clearFieldError('password'),
                  borderRadius: _fieldRadius,
                  height: _fieldHeight,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Parolni tasdiqlang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ValidatedTextField(
                  controller: _confirmPasswordController,
                  hint: 'Parolni qayta kiriting',
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _resetPassword(),
                  hasError: _fieldErrors.contains('confirmPassword'),
                  shakeTrigger: _shakeTrigger,
                  errorText: _fieldErrors.contains('confirmPassword')
                      ? 'Parollar mos kelmaydi'
                      : null,
                  enabled: !_isLoading,
                  onChanged: () => _clearFieldError('confirmPassword'),
                  borderRadius: _fieldRadius,
                  height: _fieldHeight,
                  suffix: IconButton(
                    onPressed: () {
                      setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFutureOtpNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.primary.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hozircha oddiy tiklash ishlaydi. Keyinchalik SMS yoki email orqali tasdiqlash kodi qo‘shiladi.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: _isLoading ? null : () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
      ),
    );
  }

  Widget _buildRecoverySwitcher() {
    return AnimatedSegmentSwitcher(
      selectedIndex: _usePhoneRecovery ? 0 : 1,
      labels: const ['Telefon', 'Email'],
      onChanged: (index) {
        if (_isLoading) return;
        setState(() {
          _usePhoneRecovery = index == 0;
          _fieldErrors.remove('phone');
          _fieldErrors.remove('email');
        });
      },
    );
  }

  Widget _buildPhoneFields({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ro‘yxatdan o‘tgan telefon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        InternationalPhoneField(
          controller: _phoneController,
          selectedCountry: _selectedCountry,
          onCountryChanged: (country) {
            setState(() => _selectedCountry = country);
          },
          hasError: _fieldErrors.contains('phone'),
          shakeTrigger: _shakeTrigger,
          errorText: _fieldErrors.contains('phone')
              ? 'Telefon raqamini kiriting'
              : null,
          enabled: !_isLoading,
          onChanged: () => _clearFieldError('phone'),
          borderRadius: _fieldRadius,
          height: _fieldHeight,
        ),
      ],
    );
  }

  Widget _buildEmailFields({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ro‘yxatdan o‘tgan email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ValidatedTextField(
          controller: _emailController,
          hint: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          hasError: _fieldErrors.contains('email'),
          shakeTrigger: _shakeTrigger,
          errorText: _fieldErrors.contains('email')
              ? 'Email kiriting'
              : null,
          enabled: !_isLoading,
          onChanged: () => _clearFieldError('email'),
          borderRadius: _fieldRadius,
          height: _fieldHeight,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Parolni yangilash',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
