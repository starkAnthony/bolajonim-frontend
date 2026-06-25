import 'package:flutter/material.dart';

import '../models/daily_report_field_template_model.dart';
import '../models/report_section_model.dart';
import '../theme/app_colors.dart';

class DailyReportFieldsForm extends StatefulWidget {
  final List<DailyReportFieldTemplate> templates;
  final Map<String, String> initialValues;
  final bool enabled;

  const DailyReportFieldsForm({
    super.key,
    required this.templates,
    this.initialValues = const {},
    this.enabled = true,
  });

  @override
  State<DailyReportFieldsForm> createState() => DailyReportFieldsFormState();
}

class DailyReportFieldsFormState extends State<DailyReportFieldsForm> {
  final Map<String, String> _values = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TimeOfDay?> _timeStarts = {};
  final Map<String, TimeOfDay?> _timeEnds = {};

  bool _isTimeRangeField(DailyReportFieldTemplate field) =>
      field.fieldKey == 'sleep_time' ||
      field.fieldType.toLowerCase() == 'time';

  @override
  void initState() {
    super.initState();
    for (final field in widget.templates) {
      final initial = widget.initialValues[field.fieldKey] ?? '';
      _values[field.fieldKey] = initial;
      if (_isTimeRangeField(field)) {
        _parseTimeRange(field.fieldKey, initial);
      } else if (!field.isChoice) {
        _textControllers[field.fieldKey] = TextEditingController(text: initial);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> get values => Map.unmodifiable(_values);

  List<ReportTableRowModel> buildRows() {
    return widget.templates
        .map((field) {
          final value = field.isChoice
              ? _values[field.fieldKey]
              : _isTimeRangeField(field)
                  ? _formatTimeRange(field.fieldKey)
                  : _textControllers[field.fieldKey]?.text;
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) return null;
          return ReportTableRowModel(
            fieldKey: field.fieldKey,
            label: field.label,
            value: trimmed,
          );
        })
        .whereType<ReportTableRowModel>()
        .toList();
  }

  String? validate() {
    for (final field in widget.templates) {
      if (!field.required) continue;
      final value = field.isChoice
          ? _values[field.fieldKey]
          : _isTimeRangeField(field)
              ? _formatTimeRange(field.fieldKey)
              : _textControllers[field.fieldKey]?.text;
      if (value == null || value.trim().isEmpty) {
        return '${field.label} maydonini to‘ldiring.';
      }
    }
    if (buildRows().isEmpty) {
      return 'Kamida bitta ko‘rsatkichni to‘ldiring.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.templates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kunlik ko‘rsatkichlar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Har bir qatorni to‘ldiring — ota-onalar shu jadvalni ko‘radi.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ...widget.templates.map(_buildField),
        ],
      ),
    );
  }

  Widget _buildField(DailyReportFieldTemplate field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconForField(field.fieldKey),
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  field.label + (field.required ? ' *' : ''),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (field.isChoice)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: field.choices.map((choice) {
                final selected = _values[field.fieldKey] == choice;
                return ChoiceChip(
                  label: Text(choice),
                  selected: selected,
                  onSelected: widget.enabled
                      ? (value) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _values[field.fieldKey] = value ? choice : '';
                          });
                        }
                      : null,
                  selectedColor: AppColors.primary.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFDDE4EE),
                  ),
                );
              }).toList(),
            )
          else if (_isTimeRangeField(field))
            _buildTimeRangeField(field)
          else
            TextField(
              controller: _textControllers[field.fieldKey],
              enabled: widget.enabled,
              textInputAction: TextInputAction.done,
              scrollPadding: const EdgeInsets.only(bottom: 96),
              decoration: InputDecoration(
                hintText: 'Masalan: 12:50 – 15:00',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeField(DailyReportFieldTemplate field) {
    final start = _timeStarts[field.fieldKey];
    final end = _timeEnds[field.fieldKey];

    return Row(
      children: [
        Expanded(
          child: _TimePickerTile(
            label: 'Boshlandi',
            time: start,
            enabled: widget.enabled,
            onPick: () => _pickTime(field.fieldKey, isStart: true),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textSecondary),
        ),
        Expanded(
          child: _TimePickerTile(
            label: 'Tugadi',
            time: end,
            enabled: widget.enabled,
            onPick: () => _pickTime(field.fieldKey, isStart: false),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(String fieldKey, {required bool isStart}) async {
    if (!widget.enabled) return;
    final initial = isStart ? _timeStarts[fieldKey] : _timeEnds[fieldKey];
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 13, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _timeStarts[fieldKey] = picked;
      } else {
        _timeEnds[fieldKey] = picked;
      }
      _values[fieldKey] = _formatTimeRange(fieldKey);
    });
  }

  void _parseTimeRange(String fieldKey, String raw) {
    final parts = raw.split(RegExp(r'[–\-—]'));
    if (parts.isEmpty) return;
    if (parts.length >= 2) {
      _timeStarts[fieldKey] = _parseTime(parts[0].trim());
      _timeEnds[fieldKey] = _parseTime(parts[1].trim());
    } else {
      _timeStarts[fieldKey] = _parseTime(parts[0].trim());
    }
  }

  TimeOfDay? _parseTime(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) return null;
    return TimeOfDay(
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  String _formatTimeRange(String fieldKey) {
    final start = _timeStarts[fieldKey];
    final end = _timeEnds[fieldKey];
    if (start == null && end == null) return '';
    if (start != null && end != null) {
      return '${_formatTime(start)} – ${_formatTime(end)}';
    }
    if (start != null) return _formatTime(start);
    return _formatTime(end!);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData _iconForField(String key) {
    switch (key) {
      case 'mood':
        return Icons.sentiment_satisfied_alt_outlined;
      case 'health':
        return Icons.favorite_border_rounded;
      case 'temperature':
        return Icons.thermostat_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      case 'sleep_hours':
        return Icons.bedtime_outlined;
      case 'bowel':
        return Icons.water_drop_outlined;
      case 'sleep_time':
        return Icons.schedule_outlined;
      default:
        return Icons.checklist_rounded;
    }
  }
}

/// Extract daily summary rows from report sections.
List<ReportTableRowModel> extractDailySummaryRows(
  List<ReportSectionModel> sections,
) {
  for (final section in sections) {
    if (section.sectionType == 'table' && section.rows.isNotEmpty) {
      return section.rows;
    }
  }
  return const [];
}

Map<String, String> rowsToValueMap(List<ReportTableRowModel> rows) {
  final map = <String, String>{};
  for (final row in rows) {
    final key = row.fieldKey?.trim();
    if (key != null && key.isNotEmpty) {
      map[key] = row.value;
    } else {
      map[row.label] = row.value;
    }
  }
  return map;
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final bool enabled;
  final VoidCallback onPick;

  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.enabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final display = time == null
        ? '--:--'
        : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';

    return Material(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPick : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    display,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
