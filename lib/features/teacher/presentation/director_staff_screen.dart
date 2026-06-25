import 'package:flutter/material.dart';

import '../../../core/models/staff_member_model.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/director_teacher_edit_screen.dart';

class DirectorStaffScreen extends StatefulWidget {
  const DirectorStaffScreen({super.key});

  @override
  State<DirectorStaffScreen> createState() => _DirectorStaffScreenState();
}

class _DirectorStaffScreenState extends State<DirectorStaffScreen> {
  List<StaffMemberModel> _staff = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff({bool refresh = false}) async {
    if (_staff.isEmpty) {
      setState(() => _isLoading = true);
    }
    setState(() => _error = null);

    try {
      final staff = await TeacherApi.getDirectorStaff(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _staff = staff;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _upsertTeacher(StaffMemberModel updated) {
    setState(() {
      final index = _staff.indexWhere((t) => t.userId == updated.userId);
      if (index == -1) {
        _staff = [..._staff, updated];
      } else {
        final next = List<StaffMemberModel>.from(_staff);
        next[index] = updated;
        _staff = next;
      }
    });
  }

  void _removeTeacherLocal(String userId) {
    setState(() {
      _staff = _staff.where((t) => t.userId != userId).toList();
    });
  }

  Future<void> _openTeacher(StaffMemberModel teacher) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => DirectorTeacherEditScreen(teacher: teacher),
      ),
    );

    if (!mounted || result == null) return;

    if (result is StaffMemberModel) {
      _upsertTeacher(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O‘qituvchi yangilandi.')),
      );
      await _loadStaff(refresh: true);
    } else if (result == 'removed') {
      _removeTeacherLocal(teacher.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O‘qituvchi olib tashlandi.')),
      );
      await _loadStaff(refresh: true);
    }
  }

  void _showTeacherInfo(StaffMemberModel teacher) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teacher.userName, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            if (teacher.groupName?.isNotEmpty == true)
              Text('Guruh: ${teacher.groupName}',
                  style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openTeacher(teacher);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Tahrirlash'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'O‘qituvchilar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _staff.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _staff.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Yuklab bo‘lmadi: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadStaff(refresh: true),
              child: const Text('Qayta'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadStaff(refresh: true),
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'O‘qituvchini bosing — guruh va ruxsatlarni sozlang.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          if (_staff.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Hali o‘qituvchilar yo‘q.\nTaklif kodini ulashing.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
              ),
            )
          else
            ..._staff.map(
              (teacher) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TeacherListCard(
                  key: ValueKey(teacher.userId),
                  teacher: teacher,
                  onOpen: () => _showTeacherInfo(teacher),
                  onEdit: () => _openTeacher(teacher),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeacherListCard extends StatelessWidget {
  final StaffMemberModel teacher;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  const _TeacherListCard({
    super.key,
    required this.teacher,
    required this.onOpen,
    required this.onEdit,
  });

  int get _permCount => [
        teacher.permChildEdit,
        teacher.permReportEdit,
        teacher.permAttendanceEdit,
        teacher.permEventEdit,
      ].where((p) => p).length;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  teacher.userName.isNotEmpty
                      ? teacher.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (teacher.groupName?.isNotEmpty == true)
                      Text(
                        teacher.groupName!,
                        style: AppTextStyles.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (teacher.permChildEdit)
                          const _PermBadge(
                            label: 'Bola',
                            color: Color(0xFF4CD3A6),
                          ),
                        if (teacher.permReportEdit)
                          const _PermBadge(
                            label: 'Hisobot',
                            color: Color(0xFF5BBAD5),
                          ),
                        if (teacher.permAttendanceEdit)
                          const _PermBadge(
                            label: 'Davomat',
                            color: Color(0xFF9B7BFF),
                          ),
                        if (teacher.permEventEdit)
                          const _PermBadge(
                            label: 'Tadbir',
                            color: Color(0xFFFF9F43),
                          ),
                        if (_permCount == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Ruxsat yo‘q',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB7791F),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tahrirlash',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PermBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
