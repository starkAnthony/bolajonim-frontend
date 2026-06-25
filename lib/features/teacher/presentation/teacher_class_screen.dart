import 'package:flutter/material.dart';

import '../../../core/models/staff_child_form_model.dart';
import '../../../core/models/staff_profile_model.dart';
import '../../../core/models/teacher_class_child_model.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/tab_list_screen_layout.dart';
import 'widgets/staff_child_form_dialog.dart';

class TeacherClassScreen extends StatefulWidget {
  const TeacherClassScreen({super.key});

  @override
  State<TeacherClassScreen> createState() => _TeacherClassScreenState();
}

class _TeacherClassScreenState extends State<TeacherClassScreen> {
  late Future<List<TeacherClassChildModel>> _childrenFuture;
  late Future<StaffProfileModel> _profileFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _childrenFuture = TeacherApi.getClassChildren();
    _profileFuture = TeacherApi.getProfile();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _childrenFuture = TeacherApi.getClassChildren();
      _profileFuture = TeacherApi.getProfile();
    });
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

  List<TeacherClassChildModel> _filterChildren(
    List<TeacherClassChildModel> children,
  ) {
    if (_searchQuery.isEmpty) return children;
    return children.where((child) {
      final name = child.childName.toLowerCase();
      final nick = child.nickname?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || nick.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StaffProfileModel>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        final canEditChild = profileSnapshot.data?.permChildEdit ?? false;

        return FutureBuilder<List<TeacherClassChildModel>>(
          future: _childrenFuture,
          builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ma\'lumotlarni yuklab bo\'lmadi.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final allChildren = snapshot.data ?? [];
        final children = _filterChildren(allChildren);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: TabListScreenLayout(
              title: 'Guruh',
              subtitle: 'Guruhingizdagi bolalarni boshqaring.',
              header: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Bolani qidirish...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              body: children.isEmpty
                  ? Center(
                      child: Text(
                        allChildren.isEmpty
                            ? 'Guruhda bolalar yo‘q.'
                            : 'Qidiruv bo‘yicha natija topilmadi.',
                        style: AppTextStyles.bodySmall,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _reload(),
                      color: AppColors.primary,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: children.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final child = children[index];
                          return _StudentTile(
                            child: child,
                            canEdit: canEditChild,
                            onEdit: () => _editChild(child),
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
          },
        );
      },
    );
  }
}

class _StudentTile extends StatelessWidget {
  final TeacherClassChildModel child;
  final bool canEdit;
  final VoidCallback? onEdit;

  const _StudentTile({
    required this.child,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final status = child.todayStatus.toLowerCase();
    late final Color badgeColor;
    late final Color badgeBg;

    switch (status) {
      case 'present':
        badgeColor = const Color(0xFF198754);
        badgeBg = const Color(0xFFE7F7EE);
        break;
      case 'absent':
        badgeColor = Colors.red;
        badgeBg = const Color(0xFFFFEBEE);
        break;
      default:
        badgeColor = Colors.orange;
        badgeBg = const Color(0xFFFFF4E5);
    }

    final photoUrl = BolajonimApi.resolveMediaUrl(child.photoUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canEdit ? onEdit : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEFF8F6),
            backgroundImage:
                photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(
                    Icons.child_care_rounded,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.childName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (child.nickname != null && child.nickname!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    child.nickname!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              child.displayStatus,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          if (canEdit) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }
}
