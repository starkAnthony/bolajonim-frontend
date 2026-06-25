import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/director_group_form_model.dart';
import '../../../../core/models/director_group_model.dart';
import '../../../../core/theme/app_colors.dart';

class DirectorGroupFormDialog extends StatefulWidget {
  final DirectorGroupModel? existing;

  const DirectorGroupFormDialog({super.key, this.existing});

  @override
  State<DirectorGroupFormDialog> createState() => _DirectorGroupFormDialogState();
}

class _DirectorGroupFormDialogState extends State<DirectorGroupFormDialog> {
  final _nameController = TextEditingController();
  final _ageMinController = TextEditingController();
  final _ageMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final group = widget.existing;
    if (group != null) {
      _nameController.text = group.groupName;
      if (group.ageMinYr != null) {
        _ageMinController.text = '${group.ageMinYr}';
      }
      if (group.ageMaxYr != null) {
        _ageMaxController.text = '${group.ageMaxYr}';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    super.dispose();
  }

  int? _parseAge(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  void _submit() {
    final name = _nameController.text.trim();
    final ageMin = _parseAge(_ageMinController);
    final ageMax = _parseAge(_ageMaxController);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guruh nomini kiriting.')),
      );
      return;
    }

    if (ageMin != null && ageMax != null && ageMin > ageMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal yosh maksimaldan katta bo‘lmasin.')),
      );
      return;
    }

    Navigator.pop(
      context,
      DirectorGroupFormModel(
        groupNo: widget.existing?.groupNo,
        groupName: name,
        ageMinYr: ageMin,
        ageMaxYr: ageMax,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Guruhni tahrirlash' : 'Yangi guruh',
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Guruh nomi *',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageMinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Minimal yosh',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ageMaxController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Maksimal yosh',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Yosh oralig‘i ixtiyoriy. Masalan: 2–4 yosh.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
}
