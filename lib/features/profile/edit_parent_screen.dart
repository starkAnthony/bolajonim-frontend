import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../core/models/country_phone_code.dart';
import '../../core/models/parent_profile_model.dart';
import '../../core/services/api_client.dart';
import '../../core/services/bolajonim_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/widgets/international_phone_field.dart';
import '../../core/widgets/validated_text_field.dart';

class EditParentScreen extends StatefulWidget {
  final ParentProfileModel profile;
  final ChildModel? selectedChild;

  const EditParentScreen({
    super.key,
    required this.profile,
    this.selectedChild,
  });

  @override
  State<EditParentScreen> createState() => _EditParentScreenState();
}

class _EditParentScreenState extends State<EditParentScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  CountryPhoneCode _selectedCountry = CountryPhoneCode.uzbekistan;
  String _selectedRelation = 'Ona';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.userName;
    _emailController.text = widget.profile.email?.trim() ?? '';
    _selectedRelation = widget.selectedChild?.relation ?? 'Ona';
    _initPhone(widget.profile.phone);
  }

  void _initPhone(String? phone) {
    final parsed = PhoneUtils.parseForEdit(phone);
    if (parsed == null) return;

    _selectedCountry = parsed.country;
    _phoneController.text = parsed.localFormatted;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneInput = _phoneController.text.trim();
    final phone = PhoneUtils.toInternationalIfEntered(
      _selectedCountry,
      phoneInput,
    );

    if (name.isEmpty) {
      _showMessage('Ism va familiyani kiriting.');
      return;
    }

    if (phoneInput.isNotEmpty &&
        !PhoneUtils.isValidLocalNumber(_selectedCountry, phoneInput)) {
      _showMessage('Telefon raqami noto‘g‘ri.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await BolajonimApi.updateProfile(
        userName: name,
        phone: phone,
        email: email,
      );

      final child = widget.selectedChild;
      if (child != null && _selectedRelation != (child.relation ?? 'Ona')) {
        await BolajonimApi.updateChild(
          childNo: child.childNo,
          childName: child.childName,
          nickname: child.nickname,
          birthday: BolajonimApi.formatApiDateForDisplay(child.birthDate),
          gender: child.gender ?? 'BOY',
          groupName: child.groupName ?? 'Kichik guruh',
          relation: _selectedRelation,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, updated);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Saqlashda xatolik: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Ota-ona ma’lumotlari',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Shaxsiy ma’lumotlaringizni yangilang',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text('Foydalanuvchi ID', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            _ReadOnlyField(value: widget.profile.userId),
            const SizedBox(height: 16),
            Text('Ism va familiya', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            ValidatedTextField(
              controller: _nameController,
              hint: 'Ism va familiyani kiriting',
            ),
            if (widget.selectedChild != null) ...[
              const SizedBox(height: 16),
              Text('Farzandga aloqangiz', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: _fieldDecoration(),
                items: const [
                  DropdownMenuItem(value: 'Ona', child: Text('Ona')),
                  DropdownMenuItem(value: 'Ota', child: Text('Ota')),
                  DropdownMenuItem(value: 'Vasiy', child: Text('Vasiy')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRelation = value);
                },
              ),
            ],
            const SizedBox(height: 16),
            InternationalPhoneField(
              controller: _phoneController,
              selectedCountry: _selectedCountry,
              onCountryChanged: (country) {
                setState(() => _selectedCountry = country);
              },
            ),
            const SizedBox(height: 16),
            Text('Email', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            ValidatedTextField(
              controller: _emailController,
              hint: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Saqlash',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE6EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE6EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;

  const _ReadOnlyField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
