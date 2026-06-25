import 'package:flutter/material.dart';

import '../../../core/models/director_group_detail_model.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/models/director_announcement_form_model.dart';
import '../../../core/models/director_group_form_model.dart';
import '../../../core/models/director_group_model.dart';
import '../../../core/models/staff_member_model.dart';
import '../../../core/models/teacher_class_child_model.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/director_announcement_form_dialog.dart';
import 'widgets/director_group_form_dialog.dart';

class DirectorGroupDetailScreen extends StatefulWidget {
  final DirectorGroupModel group;

  const DirectorGroupDetailScreen({super.key, required this.group});

  @override
  State<DirectorGroupDetailScreen> createState() =>
      _DirectorGroupDetailScreenState();
}

class _DirectorGroupDetailScreenState extends State<DirectorGroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<DirectorGroupDetailModel> _detailFuture;
  late TabController _tabController;
  bool _listChanged = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _detailFuture = _loadDetail();
  }

  void _reload() {
    setState(() {
      _detailFuture = _loadDetail();
    });
  }

  Future<DirectorGroupDetailModel> _loadDetail({
    DirectorGroupModel? savedGroup,
  }) async {
    final detail = await TeacherApi.getDirectorGroupDetail(
      widget.group.groupNo,
      refresh: true,
    );
    if (savedGroup == null) return detail;

    return DirectorGroupDetailModel(
      group: savedGroup.copyWith(
        childCount: detail.group.childCount,
        teacherCount: detail.group.teacherCount,
        ageMinYr: savedGroup.ageMinYr ?? detail.group.ageMinYr,
        ageMaxYr: savedGroup.ageMaxYr ?? detail.group.ageMaxYr,
      ),
      children: detail.children,
      teachers: detail.teachers,
      announcements: detail.announcements,
    );
  }

  Future<void> _editGroup(DirectorGroupModel group) async {
    final form = await showDialog<DirectorGroupFormModel>(
      context: context,
      builder: (_) => DirectorGroupFormDialog(existing: group),
    );
    if (form == null || !mounted) return;

    try {
      final updated = await TeacherApi.updateDirectorGroup(form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guruh yangilandi.')),
      );
      setState(() {
        _listChanged = true;
        _detailFuture = _loadDetail(savedGroup: updated);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  Future<void> _deleteGroup(DirectorGroupModel group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Guruhni olib tashlash'),
        content: Text('“${group.groupName}” o‘chirilsinmi?'),
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
      await TeacherApi.deleteDirectorGroup(group.groupNo);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  Future<void> _addAnnouncement(String groupName) async {
    final form = await showDialog<DirectorAnnouncementFormModel>(
      context: context,
      builder: (_) => DirectorAnnouncementFormDialog(groupName: groupName),
    );
    if (form == null || !mounted) return;

    try {
      await TeacherApi.createDirectorAnnouncement(form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E’lon yuborildi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _listChanged);
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<DirectorGroupDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yuklab bo‘lmadi: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _reload, child: const Text('Qayta')),
                  ],
                ),
              ),
            );
          }

          final detail = snapshot.data!;
          final group = detail.group;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                title: Text(group.groupName),
                actions: [
                  IconButton(
                    tooltip: 'Tahrirlash',
                    onPressed: () => _editGroup(group),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Olib tashlash',
                    onPressed: () => _deleteGroup(group),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5BBAD5), Color(0xFF8B7CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            group.ageRangeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _HeroStat(
                              label: 'Bolalar',
                              value: '${detail.children.length}',
                            ),
                            const SizedBox(width: 16),
                            _HeroStat(
                              label: 'O‘qituvchilar',
                              value: '${detail.teachers.length}',
                            ),
                            const SizedBox(width: 16),
                            _HeroStat(
                              label: 'E’lonlar',
                              value: '${detail.announcements.length}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabHeader(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Bolalar'),
                      Tab(text: 'O‘qituvchilar'),
                      Tab(text: 'E’lonlar'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _ChildrenTab(children: detail.children),
                _TeachersTab(teachers: detail.teachers),
                _AnnouncementsTab(
                  announcements: detail.announcements,
                  onAdd: () => _addAnnouncement(group.groupName),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

class _TabHeader extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabHeader(this.tabBar);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabHeader oldDelegate) => false;
}

class _ChildrenTab extends StatelessWidget {
  final List<TeacherClassChildModel> children;

  const _ChildrenTab({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const _EmptyTab(
        icon: Icons.child_care_outlined,
        message: 'Bu guruhda hali bola yo‘q.\n“Bolalar” bo‘limidan qo‘shing.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final child = children[index];
        return _EntityCard(
          icon: Icons.child_care_outlined,
          photoUrl: BolajonimApi.resolveMediaUrl(child.photoUrl),
          title: child.childName,
          subtitle: child.managementSubtitle ?? 'Guruh biriktirilmagan',
          onTap: () => _showChildInfo(context, child),
        );
      },
    );
  }

  void _showChildInfo(BuildContext context, TeacherClassChildModel child) {
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
              Text('Tug‘ilgan sana: ${child.birthDate}',
                  style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            const Text(
              'Tahrirlash uchun “Bolalar” bo‘limidagi Tahrirlash tugmasidan foydalaning.',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeachersTab extends StatelessWidget {
  final List<StaffMemberModel> teachers;

  const _TeachersTab({required this.teachers});

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) {
      return const _EmptyTab(
        icon: Icons.school_outlined,
        message: 'Bu guruhga hali o‘qituvchi biriktirilmagan.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: teachers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return _EntityCard(
          icon: Icons.school_outlined,
          title: teacher.userName,
          subtitle: _permSummary(teacher),
          onTap: () => _showTeacherInfo(context, teacher),
        );
      },
    );
  }

  String _permSummary(StaffMemberModel teacher) {
    final perms = <String>[];
    if (teacher.permChildEdit) perms.add('Bola');
    if (teacher.permReportEdit) perms.add('Hisobot');
    if (teacher.permAttendanceEdit) perms.add('Davomat');
    if (teacher.permEventEdit) perms.add('Tadbir');
    return perms.isEmpty ? 'Ruxsat berilmagan' : perms.join(' · ');
  }

  void _showTeacherInfo(BuildContext context, StaffMemberModel teacher) {
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
            Text('Guruh: ${teacher.groupName ?? '-'}',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            const Text(
              'Tahrirlash uchun “O‘qituvchilar” bo‘limidagi Tahrirlash tugmasidan foydalaning.',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final List<AnnouncementModel> announcements;
  final VoidCallback onAdd;

  const _AnnouncementsTab({
    required this.announcements,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (announcements.isEmpty)
          const _EmptyTab(
            icon: Icons.campaign_outlined,
            message: 'Bu guruh uchun e’lon yo‘q.\nPastdagi tugma orqali yuboring.',
          )
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            itemCount: announcements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = announcements[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: item.isImportant
                      ? Border.all(color: Colors.orange.withValues(alpha: 0.5))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (item.isImportant)
                          const Icon(Icons.priority_high_rounded,
                              color: Colors.orange, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.preview, style: AppTextStyles.bodySmall),
                    if (item.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Text(item.createdAt!, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              );
            },
          ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            heroTag: 'group-announcement-fab',
            onPressed: onAdd,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('E’lon yuborish'),
          ),
        ),
      ],
    );
  }
}

class _EntityCard extends StatelessWidget {
  final IconData icon;
  final String? photoUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EntityCard({
    required this.icon,
    this.photoUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? Icon(icon, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
