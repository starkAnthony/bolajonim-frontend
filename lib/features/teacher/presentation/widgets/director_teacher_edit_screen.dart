import 'package:flutter/material.dart';

import '../../../../core/models/staff_member_model.dart';
import '../../../../core/services/teacher_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../staff_personal_profile_screen.dart';
import 'director_group_picker.dart';

class DirectorTeacherEditScreen extends StatefulWidget {
  final StaffMemberModel teacher;

  const DirectorTeacherEditScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<DirectorTeacherEditScreen> createState() =>
      _DirectorTeacherEditScreenState();
}

class _DirectorTeacherEditScreenState extends State<DirectorTeacherEditScreen> {
  String? _selectedGroupName;
  late bool _permChild;
  late bool _permReport;
  late bool _permAttendance;
  late bool _permEvent;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupName = widget.teacher.groupName;
    _permChild = widget.teacher.permChildEdit;
    _permReport = widget.teacher.permReportEdit;
    _permAttendance = widget.teacher.permAttendanceEdit;
    _permEvent = widget.teacher.permEventEdit;
  }

  @override
  void dispose() {
    super.dispose();
  }

  int get _activePermCount =>
      [_permChild, _permReport, _permAttendance, _permEvent]
          .where((p) => p)
          .length;

  void _setAllPermissions(bool value) {
    setState(() {
      _permChild = value;
      _permReport = value;
      _permAttendance = value;
      _permEvent = value;
    });
  }

  Future<void> _save() async {
    final groupName = _selectedGroupName?.trim() ?? '';
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guruhni tanlang.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await TeacherApi.updateDirectorStaff(
        userId: widget.teacher.userId,
        groupName: groupName,
        permChildEdit: _permChild,
        permReportEdit: _permReport,
        permAttendanceEdit: _permAttendance,
        permEventEdit: _permEvent,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        widget.teacher.copyWith(
          groupName: groupName,
          permChildEdit: _permChild,
          permReportEdit: _permReport,
          permAttendanceEdit: _permAttendance,
          permEventEdit: _permEvent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saqlashda xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Olib tashlash'),
        content: Text(
          '${widget.teacher.userName} bog‘chadan olib tashlansinmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Olib tashlash',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await TeacherApi.removeDirectorStaff(widget.teacher.userId);
      if (!mounted) return;
      Navigator.pop(context, 'removed');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacher = widget.teacher;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'O‘qituvchi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          teacher.userName.isNotEmpty
                              ? teacher.userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activePermCount == 0
                                  ? 'Ruxsat berilmagan'
                                  : '$_activePermCount ta ruxsat faol',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _activePermCount == 0
                                    ? Colors.orange.shade700
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  onTap: _isSaving
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StaffPersonalProfileScreen(
                                userId: teacher.userId,
                                readOnly: true,
                              ),
                            ),
                          );
                        },
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Shaxsiy ma’lumotlar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Rasm, laqab, yosh, manzil',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Guruh',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DirectorGroupPicker(
                  initialGroupName: _selectedGroupName,
                  enabled: !_isSaving,
                  onChanged: (value) =>
                      setState(() => _selectedGroupName = value),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ruxsatlar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _setAllPermissions(_activePermCount < 4),
                      icon: Icon(
                        _activePermCount == 4
                            ? Icons.remove_circle_outline
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        _activePermCount == 4 ? 'Hammasini o‘chirish' : 'Hammasini berish',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'O‘qituvchi faqat yoqilgan amallarni bajara oladi.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                _PermissionCard(
                  icon: Icons.child_care_rounded,
                  iconColor: const Color(0xFF4CD3A6),
                  title: 'Bola ma’lumotlari',
                  description: 'Guruhdagi bolalar profilini tahrirlash',
                  value: _permChild,
                  onChanged: _isSaving
                      ? null
                      : (v) => setState(() => _permChild = v),
                ),
                const SizedBox(height: 10),
                _PermissionCard(
                  icon: Icons.edit_note_rounded,
                  iconColor: const Color(0xFF5BBAD5),
                  title: 'Kunlik hisobotlar',
                  description: 'Bolalar uchun kunlik hisobot yozish',
                  value: _permReport,
                  onChanged: _isSaving
                      ? null
                      : (v) => setState(() => _permReport = v),
                ),
                const SizedBox(height: 10),
                _PermissionCard(
                  icon: Icons.fact_check_outlined,
                  iconColor: const Color(0xFF9B7BFF),
                  title: 'Davomat',
                  description: 'Keldi / kelmadi holatini belgilash',
                  value: _permAttendance,
                  onChanged: _isSaving
                      ? null
                      : (v) => setState(() => _permAttendance = v),
                ),
                const SizedBox(height: 10),
                _PermissionCard(
                  icon: Icons.event_rounded,
                  iconColor: const Color(0xFFFF9F43),
                  title: 'Tadbirlar va jadval',
                  description: 'Guruh tadbirlari va kun tartibini boshqarish',
                  value: _permEvent,
                  onChanged: _isSaving
                      ? null
                      : (v) => setState(() => _permEvent = v),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _isSaving ? null : _remove,
                  icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                  label: const Text(
                    'O‘qituvchini bog‘chadan olib tashlash',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Saqlash',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
