import 'package:flutter/material.dart';

import '../models/child_model.dart';
import '../theme/app_colors.dart';

Future<void> showChildSwitcherSheet({
  required BuildContext context,
  required List<ChildModel> children,
  required String? selectedChildNo,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EAF0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Farzandni tanlang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (final child in children)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: selectedChildNo == child.childNo
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : const Color(0xFFF4F6F9),
                    child: Icon(
                      Icons.child_friendly_rounded,
                      color: selectedChildNo == child.childNo
                          ? AppColors.primary
                          : Colors.black54,
                    ),
                  ),
                  title: Text(
                    child.childName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: child.displaySubtitle.isNotEmpty
                      ? Text(child.displaySubtitle)
                      : null,
                  trailing: selectedChildNo == child.childNo
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onSelected(child.childNo);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
