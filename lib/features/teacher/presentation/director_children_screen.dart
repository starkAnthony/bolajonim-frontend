import 'package:flutter/material.dart';

import '../../../core/models/staff_child_form_model.dart';
import '../../../core/models/teacher_class_child_model.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/staff_child_form_dialog.dart';

class DirectorChildrenScreen extends StatefulWidget {
  const DirectorChildrenScreen({super.key});

  @override
  State<DirectorChildrenScreen> createState() => _DirectorChildrenScreenState();
}

class _DirectorChildrenScreenState extends State<DirectorChildrenScreen> {
  late Future<List<TeacherClassChildModel>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = TeacherApi.getClassChildren();
  }

  void _reload() {
    setState(() {
      _childrenFuture = TeacherApi.getClassChildren();
    });
  }

  Future<void> _addChild() async {
    final form = await showDialog<StaffChildFormModel>(
      context: context,
      builder: (_) => const StaffChildFormDialog(),
    );
    if (form == null || !mounted) return;

    try {
      await TeacherApi.createDirectorChild(form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bola qo‘shildi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  Future<void> _editChild(TeacherClassChildModel child) async {
    final form = await showDialog<StaffChildFormModel>(
      context: context,
      builder: (_) => StaffChildFormDialog(existing: child),
    );
    if (form == null || !mounted) return;

    try {
      await TeacherApi.updateStaffChild(form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bola yangilandi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  Future<void> _deleteChild(TeacherClassChildModel child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bolani olib tashlash'),
        content: Text('${child.childName} ro‘yxatdan olib tashlansinmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Olib tashlash'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await TeacherApi.deleteDirectorChild(child.childNo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bola olib tashlandi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  void _showChildInfo(TeacherClassChildModel child) {
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
            Text(child.childName, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            if (child.groupName?.isNotEmpty == true)
              Text('Guruh: ${child.groupName}', style: AppTextStyles.bodySmall),
            if (child.birthDate?.isNotEmpty == true)
              Text(
                'Tug‘ilgan sana: ${child.birthDate}',
                style: AppTextStyles.bodySmall,
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _editChild(child);
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'director-children-fab',
        onPressed: _addChild,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yangi bola'),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Bolalar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<List<TeacherClassChildModel>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Yuklab bo‘lmadi: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _reload, child: const Text('Qayta')),
                ],
              ),
            );
          }

          final children = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              children: [
                const Text(
                  'Bog‘chadagi barcha bolalarni qo‘shing, tahrirlang yoki olib tashlang.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),
                if (children.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Hali bolalar yo‘q.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  )
                else
                  ...children.map(
                    (child) {
                      final photoUrl =
                          BolajonimApi.resolveMediaUrl(child.photoUrl);
                      return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => _showChildInfo(child),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null
                                      ? const Icon(
                                          Icons.child_care_outlined,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        child.childName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (child.managementSubtitle != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          child.managementSubtitle!,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Tahrirlash',
                                  onPressed: () => _editChild(child),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editChild(child);
                                    } else if (value == 'remove') {
                                      _deleteChild(child);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Tahrirlash'),
                                    ),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Olib tashlash'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
