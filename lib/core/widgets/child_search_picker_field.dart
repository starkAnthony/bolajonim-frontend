import 'package:flutter/material.dart';

import '../models/teacher_class_child_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Searchable child selector — better than a long dropdown when many children.
class ChildSearchPickerField extends StatelessWidget {
  final List<TeacherClassChildModel> children;
  final String selectedChildNo;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String label;

  const ChildSearchPickerField({
    super.key,
    required this.children,
    required this.selectedChildNo,
    required this.onSelected,
    this.enabled = true,
    this.label = 'Bola *',
  });

  TeacherClassChildModel? get _selected {
    for (final child in children) {
      if (child.childNo == selectedChildNo) return child;
    }
    return children.isEmpty ? null : children.first;
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled || children.isEmpty) return;

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _ChildSearchPickerSheet(
        children: children,
        selectedChildNo: selectedChildNo,
      ),
    );

    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: enabled ? AppColors.inputFill : AppColors.inputFill.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? () => _openPicker(context) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected?.childName ?? 'Bolani tanlang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: selected == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (selected?.managementSubtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            selected!.managementSubtitle!,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (enabled)
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildSearchPickerSheet extends StatefulWidget {
  final List<TeacherClassChildModel> children;
  final String selectedChildNo;

  const _ChildSearchPickerSheet({
    required this.children,
    required this.selectedChildNo,
  });

  @override
  State<_ChildSearchPickerSheet> createState() => _ChildSearchPickerSheetState();
}

class _ChildSearchPickerSheetState extends State<_ChildSearchPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherClassChildModel> get _filtered {
    if (_query.isEmpty) return widget.children;
    return widget.children.where((child) {
      final haystack = [
        child.childName,
        child.nickname ?? '',
        child.groupName ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DDE3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bolani tanlang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ism yoki guruh bo‘yicha qidirish...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Natija topilmadi.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final child = filtered[index];
                          final isSelected =
                              child.childNo == widget.selectedChildNo;
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : null,
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.12),
                              child: const Icon(
                                Icons.child_care_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              child.childName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: child.managementSubtitle != null
                                ? Text(child.managementSubtitle!)
                                : null,
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () =>
                                Navigator.pop(context, child.childNo),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
