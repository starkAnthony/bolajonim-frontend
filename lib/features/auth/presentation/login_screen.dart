import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../navigation/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _usePhoneLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final loginValue = _usePhoneLogin
        ? _phoneController.text.replaceAll('-', '').trim()
        : _emailController.text.trim();

    final password = _passwordController.text.trim();

    if (_usePhoneLogin) {
      if (loginValue.isEmpty || loginValue.length != 9) {
        _showSnack('Telefon raqamni to\'liq kiriting');
        return;
      }
    } else {
      if (loginValue.isEmpty) {
        _showSnack('Email kiriting');
        return;
      }
    }

    if (password.isEmpty) {
      _showSnack('Parolni kiriting');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // await AuthService.login(userId: loginValue, password: password);

      // if (!mounted) return;

      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      //   (route) => false,
      // );
      // 🔥 TEMPORARY: skip backend
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _handleAuthError(e);
    } on http.ClientException {
      if (!mounted) return;
      _showSnack('Serverga ulanib bo\'lmadi.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Xato: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleAuthError(AuthException e) {
    const messages = {
      'OVER_FAIL_COUNT':
          'Kirish urinishlari soni oshib ketdi. Administratorga murojaat qiling.',
      'INVALID_USER_INFO': 'Login yoki parol noto\'g\'ri.',
      'LONG_TERM_NO_LOGIN_USER': 'Uzoq vaqt kirish amalga oshirilmagan.',
      'USER_RESIGNED': 'Bu hisob faol emas.',
      'PWD_CHANGE_NECESSITY': 'Parolni yangilash zarur.',
      'PWD_INIT_STATE': 'Parolingiz tiklangan. Yangi parol o\'rnating.',
    };

    final displayMessage =
        (e.type != null ? messages[e.type] : null) ?? e.message;
    _showSnack(displayMessage);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    44,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 28),
                    const Text(
                      'Xush kelibsiz',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sahifangizga kiring',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    _buildLoginTypeSwitcher(),
                    const SizedBox(height: 28),
                    if (_usePhoneLogin) ...[
                      const Text(
                        'Telefon raqam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPhoneField(),
                    ] else ...[
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEmailField(),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Parol',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(),
                    const SizedBox(height: 28),
                    _buildLoginButton(),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Parolni unutdingizmi?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 22,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLoginTypeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_usePhoneLogin) setState(() => _usePhoneLogin = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _usePhoneLogin
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Telefon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _usePhoneLogin ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_usePhoneLogin) setState(() => _usePhoneLogin = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_usePhoneLogin
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: !_usePhoneLogin ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    const borderRadius = 20.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.7),
              width: 1.5,
            ),
          ),
          child: const Text(
            '+998',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 64,
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                UzbekPhoneNumberFormatter(),
              ],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: '90-123-45-67',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.65),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.7),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'email@example.com',
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.65),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.7),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Parolingizni kiriting',
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.65),
        suffixIcon: IconButton(
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.7),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Kirish',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

class UzbekPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 9) digits = digits.substring(0, 9);

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 1 && digits.length > 2) {
        buffer.write('-');
      } else if (i == 4 && digits.length > 5) {
        buffer.write('-');
      } else if (i == 6 && digits.length > 7) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
