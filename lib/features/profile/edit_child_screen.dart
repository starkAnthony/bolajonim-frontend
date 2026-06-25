import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../core/services/api_client.dart';
import '../../core/services/bolajonim_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EditChildScreen extends StatefulWidget {
  final ChildModel child;

  const EditChildScreen({super.key, required this.child});

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _childNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _groupController = TextEditingController();

  String _selectedGender = 'BOY';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _childNameController.text = widget.child.childName;
    _nicknameController.text = widget.child.nickname ?? '';
    _birthdayController.text =
        BolajonimApi.formatApiDateForDisplay(widget.child.birthDate);
    _groupController.text = widget.child.groupName ?? '';
    _selectedGender = (widget.child.gender ?? 'BOY').toUpperCase();
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _nicknameController.dispose();
    _birthdayController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2015),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _birthdayController.text =
          '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}';
    }
  }

  Future<void> _save() async {
    final childName = _childNameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final group = _groupController.text.trim();

    if (childName.isEmpty || birthday.isEmpty) {
      _showMessage('Iltimos, majburiy maydonlarni to‘ldiring.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await BolajonimApi.updateChild(
        childNo: widget.child.childNo,
        childName: childName,
        nickname: _nicknameController.text.trim(),
        birthday: birthday,
        gender: _selectedGender,
        groupName: group.isEmpty ? 'Kichik guruh' : group,
      );

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
          'Farzand ma’lumotlari',
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
            _label('Bolaning to‘liq ismi *'),
            const SizedBox(height: 8),
            _input(controller: _childNameController, hint: 'Ism va familiyasi'),
            const SizedBox(height: 16),
            _label('Tahallus'),
            const SizedBox(height: 8),
            _input(controller: _nicknameController, hint: 'Masalan: Ali'),
            const SizedBox(height: 16),
            _label('Tug‘ilgan sana *'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectBirthday,
              child: AbsorbPointer(
                child: _input(
                  controller: _birthdayController,
                  hint: 'kk.oo.yyyy',
                  suffixIcon: Icons.calendar_today_rounded,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _label('Jinsi'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _genderChip("O'g'il", 'BOY')),
                const SizedBox(width: 10),
                Expanded(child: _genderChip('Qiz', 'GIRL')),
              ],
            ),
            const SizedBox(height: 16),
            _label('Guruh / sinf'),
            const SizedBox(height: 8),
            _input(controller: _groupController, hint: 'Masalan: Kichik guruh'),
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

  Widget _genderChip(String label, String value) {
    final selected = _selectedGender == value;
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF8F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE6EAF0),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: AppTextStyles.titleLarge);

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

  Widget _input({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: _fieldDecoration().copyWith(
        hintText: hint,
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
      ),
    );
  }
}
