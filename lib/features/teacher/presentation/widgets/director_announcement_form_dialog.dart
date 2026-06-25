import 'package:flutter/material.dart';
import '../../../../core/models/director_announcement_form_model.dart';
import '../../../../core/theme/app_colors.dart';

class DirectorAnnouncementFormDialog extends StatefulWidget {
  final String groupName;

  const DirectorAnnouncementFormDialog({
    super.key,
    required this.groupName,
  });

  @override
  State<DirectorAnnouncementFormDialog> createState() =>
      _DirectorAnnouncementFormDialogState();
}

class _DirectorAnnouncementFormDialogState
    extends State<DirectorAnnouncementFormDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _type = 'announcement';
  bool _isImportant = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sarlavha va matnni kiriting.')),
      );
      return;
    }

    Navigator.pop(
      context,
      DirectorAnnouncementFormModel(
        title: title,
        content: content,
        type: _type,
        isImportant: _isImportant,
        groupName: widget.groupName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '“${widget.groupName}” uchun e’lon',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Sarlavha *',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Matn *',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _typeChip('E’lon', 'announcement')),
                const SizedBox(width: 8),
                Expanded(child: _typeChip('Tadbir', 'event')),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Muhim e’lon'),
              value: _isImportant,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
              onChanged: (value) => setState(() => _isImportant = value),
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
          child: const Text('Yuborish'),
        ),
      ],
    );
  }

  Widget _typeChip(String label, String value) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
