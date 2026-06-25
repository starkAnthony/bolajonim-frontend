import 'package:flutter/material.dart';

import '../../../../core/models/staff_child_form_model.dart';
import '../../../../core/models/teacher_class_child_model.dart';
import '../../../../core/theme/app_colors.dart';
import 'director_group_picker.dart';

class StaffChildFormDialog extends StatefulWidget {
  final TeacherClassChildModel? existing;

  const StaffChildFormDialog({super.key, this.existing});

  @override
  State<StaffChildFormDialog> createState() => _StaffChildFormDialogState();
}

class _StaffChildFormDialogState extends State<StaffChildFormDialog> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? _selectedGroupName;
  String _gender = 'BOY';

  @override
  void initState() {
    super.initState();
    final child = widget.existing;
    if (child != null) {
      _nameController.text = child.childName;
      _nicknameController.text = child.nickname ?? '';
      _birthdayController.text = _displayDate(child.birthDate);
      _selectedGroupName = child.groupName;
      _gender = (child.genderCode ?? 'BOY').toUpperCase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  String _displayDate(String? apiDate) {
    if (apiDate == null || apiDate.length != 8) return '';
    return '${apiDate.substring(6, 8)}.${apiDate.substring(4, 6)}.${apiDate.substring(0, 4)}';
  }

  String _toApiDate(String value) {
    final parts = value.split('.');
    if (parts.length != 3) return value;
    return '${parts[2]}${parts[1]}${parts[0]}';
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 3),
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
    if (picked != null) {
      _birthdayController.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final group = _selectedGroupName?.trim() ?? '';

    if (name.isEmpty || birthday.isEmpty || group.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ism, tug‘ilgan sana va guruhni tanlang.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      StaffChildFormModel(
        childNo: widget.existing?.childNo,
        childName: name,
        nickname: _nicknameController.text.trim(),
        birthDate: _toApiDate(birthday),
        genderCode: _gender,
        groupName: group,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Bolani tahrirlash' : 'Yangi bola',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Ism *', _nameController),
            const SizedBox(height: 12),
            _field('Tahallus', _nicknameController),
            const SizedBox(height: 12),
            TextField(
              controller: _birthdayController,
              readOnly: true,
              onTap: _pickBirthday,
              decoration: InputDecoration(
                labelText: 'Tug‘ilgan sana *',
                suffixIcon: IconButton(
                  onPressed: _pickBirthday,
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _genderChip("O'g'il", 'BOY')),
                const SizedBox(width: 8),
                Expanded(child: _genderChip('Qiz', 'GIRL')),
              ],
            ),
            const SizedBox(height: 12),
            DirectorGroupPicker(
              initialGroupName: _selectedGroupName,
              onChanged: (value) => setState(() => _selectedGroupName = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? 'Saqlash' : 'Qo‘shish'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _genderChip(String label, String value) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
