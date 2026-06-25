import 'package:flutter/material.dart';

import '../../../../core/models/director_group_form_model.dart';
import '../../../../core/models/director_group_model.dart';
import '../../../../core/services/teacher_api.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'director_group_form_dialog.dart';

class DirectorGroupPicker extends StatefulWidget {
  final String? initialGroupName;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const DirectorGroupPicker({
    super.key,
    this.initialGroupName,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<DirectorGroupPicker> createState() => _DirectorGroupPickerState();
}

class _DirectorGroupPickerState extends State<DirectorGroupPicker> {
  List<DirectorGroupModel> _groups = [];
  String? _selectedGroupName;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedGroupName = widget.initialGroupName?.trim().isNotEmpty == true
        ? widget.initialGroupName!.trim()
        : null;
    _loadGroups();
  }

  Future<void> _loadGroups({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final groups = await TeacherApi.getDirectorGroups(refresh: refresh);
      if (!mounted) return;

      String? selected = _selectedGroupName;
      if (selected != null &&
          !groups.any((group) => group.groupName == selected)) {
        selected = null;
      }
      selected ??= groups.isNotEmpty ? groups.first.groupName : null;

      setState(() {
        _groups = groups;
        _selectedGroupName = selected;
        _isLoading = false;
      });
      widget.onChanged(_selectedGroupName);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createGroup() async {
    final form = await showDialog<DirectorGroupFormModel>(
      context: context,
      builder: (_) => const DirectorGroupFormDialog(),
    );

    if (form == null || !mounted) return;

    try {
      final group = await TeacherApi.createDirectorGroup(form);
      if (!mounted) return;
      await _loadGroups(refresh: true);
      if (!mounted) return;
      setState(() => _selectedGroupName = group.groupName);
      widget.onChanged(group.groupName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('“${group.groupName}” qo‘shildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guruh qo‘shilmadi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guruhlar yuklanmadi: $_error', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _loadGroups, child: const Text('Qayta')),
        ],
      );
    }

    if (_groups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hali guruh yo‘q. Avval guruh yarating — bolalar va o‘qituvchilar shu nom bilan bog‘lanadi.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.enabled ? _createGroup : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Birinchi guruhni yaratish'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedGroupName,
          decoration: const InputDecoration(
            labelText: 'Guruh *',
          ),
          items: _groups
              .map(
                (group) => DropdownMenuItem(
                  value: group.groupName,
                  child: Text(
                    group.ageMinYr != null || group.ageMaxYr != null
                        ? '${group.groupName} (${group.ageRangeLabel})'
                        : group.groupName,
                  ),
                ),
              )
              .toList(),
          onChanged: widget.enabled
              ? (value) {
                  setState(() => _selectedGroupName = value);
                  widget.onChanged(value);
                }
              : null,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.enabled ? _createGroup : null,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Yangi guruh qo‘shish'),
          ),
        ),
      ],
    );
  }
}
