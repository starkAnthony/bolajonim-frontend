import 'package:flutter/material.dart';

import '../../core/models/daily_report_field_template_model.dart';
import '../../core/services/teacher_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DailyReportTemplateSettingsScreen extends StatefulWidget {
  const DailyReportTemplateSettingsScreen({super.key});

  @override
  State<DailyReportTemplateSettingsScreen> createState() =>
      _DailyReportTemplateSettingsScreenState();
}

class _DailyReportTemplateSettingsScreenState
    extends State<DailyReportTemplateSettingsScreen> {
  late Future<List<DailyReportFieldTemplate>> _templateFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _templateFuture = TeacherApi.getDailyReportFieldTemplate();
  }

  void _reload() {
    setState(() {
      _templateFuture = TeacherApi.getDailyReportFieldTemplate();
    });
  }

  Future<void> _editField({
    DailyReportFieldTemplate? existing,
    required List<DailyReportFieldTemplate> all,
  }) async {
    final result = await showDialog<DailyReportFieldTemplate>(
      context: context,
      builder: (_) => _FieldEditorDialog(existing: existing),
    );
    if (result == null) return;

    final updated = List<DailyReportFieldTemplate>.from(all);
    if (existing != null) {
      final index = updated.indexWhere((f) => f.fieldKey == existing.fieldKey);
      if (index >= 0) updated[index] = result;
    } else {
      updated.add(result.copyWith(sortOrder: updated.length + 1));
    }
    await _save(updated);
  }

  Future<void> _save(List<DailyReportFieldTemplate> fields) async {
    setState(() => _isSaving = true);
    try {
      final normalized = <DailyReportFieldTemplate>[];
      for (var i = 0; i < fields.length; i++) {
        final field = fields[i];
        normalized.add(DailyReportFieldTemplate(
          fieldNo: field.fieldNo,
          fieldKey: field.fieldKey.isNotEmpty
              ? field.fieldKey
              : 'field_${i + 1}',
          label: field.label,
          fieldType: field.fieldType,
          choices: field.choices,
          sortOrder: i + 1,
          required: field.required,
        ));
      }
      await TeacherApi.saveDailyReportFieldTemplate(normalized);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunlik hisobot shabloni saqlandi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saqlashda xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Kunlik hisobot shabloni',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving
            ? null
            : () async {
                final fields = await _templateFuture;
                if (!mounted) return;
                await _editField(all: fields);
              },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Maydon qo‘shish'),
      ),
      body: FutureBuilder<List<DailyReportFieldTemplate>>(
        future: _templateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Yuklab bo‘lmadi: ${snapshot.error}'));
          }

          final fields = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              Text(
                'O‘qituvchilar kunlik hisobot yozganda shu maydonlarni to‘ldiradi. Har bir bog‘cha uchun alohida sozlash mumkin.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              ...fields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TemplateFieldCard(
                    field: field,
                    onEdit: () => _editField(existing: field, all: fields),
                    onDelete: () async {
                      final updated = fields
                          .where((f) => f.fieldKey != field.fieldKey)
                          .toList();
                      if (updated.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kamida bitta maydon qolishi kerak.'),
                          ),
                        );
                        return;
                      }
                      await _save(updated);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on DailyReportFieldTemplate {
  DailyReportFieldTemplate copyWith({
    int? fieldNo,
    String? fieldKey,
    String? label,
    String? fieldType,
    List<String>? choices,
    int? sortOrder,
    bool? required,
  }) {
    return DailyReportFieldTemplate(
      fieldNo: fieldNo ?? this.fieldNo,
      fieldKey: fieldKey ?? this.fieldKey,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      choices: choices ?? this.choices,
      sortOrder: sortOrder ?? this.sortOrder,
      required: required ?? this.required,
    );
  }
}

class _TemplateFieldCard extends StatelessWidget {
  final DailyReportFieldTemplate field;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateFieldCard({
    required this.field,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          Text(
            field.isChoice
                ? 'Tanlov: ${field.choices.join(', ')}'
                : 'Matn maydoni',
            style: AppTextStyles.bodySmall,
          ),
          if (field.required)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Majburiy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FieldEditorDialog extends StatefulWidget {
  final DailyReportFieldTemplate? existing;

  const _FieldEditorDialog({this.existing});

  @override
  State<_FieldEditorDialog> createState() => _FieldEditorDialogState();
}

class _FieldEditorDialogState extends State<_FieldEditorDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _choicesController;
  late String _fieldType;
  late bool _required;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _choicesController = TextEditingController(
      text: existing?.choices.join(', ') ?? '',
    );
    _fieldType = existing?.fieldType ?? 'choice';
    _required = existing?.required ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _choicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Yangi maydon' : 'Maydonni tahrirlash'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Nomi'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fieldType,
              decoration: const InputDecoration(labelText: 'Turi'),
              items: const [
                DropdownMenuItem(value: 'choice', child: Text('Tanlov (chip)')),
                DropdownMenuItem(value: 'text', child: Text('Matn')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _fieldType = value);
              },
            ),
            if (_fieldType == 'choice') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _choicesController,
                decoration: const InputDecoration(
                  labelText: 'Variantlar',
                  hintText: 'Vergul bilan: Yaxshi, O‘rtacha, Yomon',
                ),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Majburiy'),
              value: _required,
              onChanged: (value) => setState(() => _required = value),
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
          onPressed: () {
            final label = _labelController.text.trim();
            if (label.isEmpty) return;
            final choices = _fieldType == 'choice'
                ? _choicesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : <String>[];
            if (_fieldType == 'choice' && choices.isEmpty) return;
            Navigator.pop(
              context,
              DailyReportFieldTemplate(
                fieldNo: widget.existing?.fieldNo,
                fieldKey: widget.existing?.fieldKey ??
                    label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
                label: label,
                fieldType: _fieldType,
                choices: choices,
                sortOrder: widget.existing?.sortOrder ?? 0,
                required: _required,
              ),
            );
          },
          child: const Text('Saqlash'),
        ),
      ],
    );
  }
}
