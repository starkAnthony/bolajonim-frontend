import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/session_service.dart';
import '../../../core/models/country_phone_code.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/animated_segment_switcher.dart';
import '../../../core/widgets/international_phone_field.dart';
import '../../../core/widgets/validated_text_field.dart';
import '../../child/child_setup_screen.dart';
import '../../navigation/main_navigation_screen.dart';
import '../../teacher/presentation/teacher_main_navigation_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? successMessage;

  const LoginScreen({super.key, this.successMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double _fieldHeight = 64;
  static const double _fieldRadius = 20;

  bool _usePhoneLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _shakeTrigger = 0;
  CountryPhoneCode _selectedCountry = CountryPhoneCode.uzbekistan;

  final Set<String> _fieldErrors = {};

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showSnack(widget.successMessage!);
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitLogin([String? _]) {
    if (!_isLoading) {
      _login();
    }
  }

  void _focusPasswordField([String? _]) {
    _passwordFocusNode.requestFocus();
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.remove(field)) {
      setState(() {});
    }
  }

  bool _validateLoginForm() {
    final errors = <String>{};
    final password = _passwordController.text.trim();

    if (_usePhoneLogin) {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || !PhoneUtils.isValidLocalNumber(_selectedCountry, phone)) {
        errors.add('phone');
      }
    } else {
      final loginValue = _emailController.text.trim();
      if (loginValue.isEmpty) {
        errors.add('email');
      }
    }

    if (password.isEmpty) {
      errors.add('password');
    }

    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
      if (errors.isNotEmpty) _shakeTrigger++;
    });

    if (errors.isNotEmpty) {
      _showSnack('Iltimos, qizil belgilangan maydonlarni to‘ldiring.');
      return false;
    }

    return true;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_validateLoginForm()) return;

    final loginValue = _usePhoneLogin
        ? PhoneUtils.toInternational(_selectedCountry, _phoneController.text)
        : _emailController.text.trim();

    final password = _passwordController.text.trim();
    final loginType = _usePhoneLogin
        ? 'PHONE'
        : (loginValue.contains('@') ? 'EMAIL' : 'USER_ID');

    setState(() => _isLoading = true);

    try {
      final userId = await BolajonimApi.resolveLoginId(
        loginValue: loginValue,
        loginType: loginType,
      );

      final loginResult = await AuthService.login(
        userId: userId,
        password: password,
      );

      if (!mounted) return;

      final result = loginResult['result'] as Map<String, dynamic>?;
      await SessionService.saveRole(result?['rofcCd']?.toString());
      final role = await SessionService.getRole();

      if (!mounted) return;

      if (role == UserRole.parent) {
        var children = <dynamic>[];
        try {
          children = await BolajonimApi.getChildren();
        } catch (_) {
          // New parent or profile API not ready yet — still go to child setup.
        }

        if (!mounted) return;

        if (children.isEmpty) {
          final inviteCode = await SessionService.consumePendingInviteCode();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ChildSetupScreen(
                initialInviteCode: inviteCode,
              ),
            ),
            (route) => false,
          );
          return;
        }
      }

      final Widget destination = switch (role) {
        UserRole.teacher => const TeacherMainNavigationScreen(),
        UserRole.director =>
          const TeacherMainNavigationScreen(isDirector: true),
        _ => const MainNavigationScreen(),
      };

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _handleAuthError(e);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      if (message.contains('User not found')) {
        _showSnack(
          'Foydalanuvchi topilmadi. Avval ro\'yxatdan o\'ting yoki ma\'lumotlarni tekshiring.',
        );
      } else {
        _showSnack('Xato: $message');
      }
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
      'INVALID_USER_INFO': 'Telefon, ID, email yoki parol noto\'g\'ri.',
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
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  child: SegmentContentTransition(
                    child: _usePhoneLogin
                        ? _buildPhoneLoginFields(key: const ValueKey('phone'))
                        : _buildEmailLoginFields(key: const ValueKey('email')),
                  ),
                ),
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
                ValidatedTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hint: 'Parolingizni kiriting',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _submitLogin,
                  hasError: _fieldErrors.contains('password'),
                  shakeTrigger: _shakeTrigger,
                  errorText: _fieldErrors.contains('password')
                      ? 'Parolni kiriting'
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
                const SizedBox(height: 28),
                _buildLoginButton(),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
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
              ],
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
    return AnimatedSegmentSwitcher(
      selectedIndex: _usePhoneLogin ? 0 : 1,
      labels: const ['Telefon', 'Email'],
      onChanged: (index) {
        setState(() {
          _usePhoneLogin = index == 0;
          _fieldErrors.clear();
        });
      },
    );
  }

  Widget _buildPhoneLoginFields({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Telefon raqam',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        InternationalPhoneField(
          controller: _phoneController,
          selectedCountry: _selectedCountry,
          onCountryChanged: (country) {
            setState(() => _selectedCountry = country);
            _clearFieldError('phone');
          },
          hasError: _fieldErrors.contains('phone'),
          shakeTrigger: _shakeTrigger,
          errorText: _fieldErrors.contains('phone')
              ? 'Telefon raqamni to‘liq kiriting'
              : null,
          enabled: !_isLoading,
          onChanged: () => _clearFieldError('phone'),
          borderRadius: _fieldRadius,
          height: _fieldHeight,
          textInputAction: TextInputAction.next,
          onSubmitted: _focusPasswordField,
        ),
      ],
    );
  }

  Widget _buildEmailLoginFields({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email yoki ID',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ValidatedTextField(
          controller: _emailController,
          hint: 'email@example.com yoki login ID',
          keyboardType: TextInputType.emailAddress,
          hasError: _fieldErrors.contains('email'),
          shakeTrigger: _shakeTrigger,
          errorText: _fieldErrors.contains('email')
              ? 'Email yoki login ID kiriting'
              : null,
          enabled: !_isLoading,
          onChanged: () => _clearFieldError('email'),
          borderRadius: _fieldRadius,
          height: _fieldHeight,
          textInputAction: TextInputAction.next,
          onSubmitted: _focusPasswordField,
        ),
      ],
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
