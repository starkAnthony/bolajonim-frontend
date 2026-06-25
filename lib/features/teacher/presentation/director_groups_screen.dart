import 'package:flutter/material.dart';

import '../../../core/models/director_group_form_model.dart';
import '../../../core/models/director_group_model.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/tab_list_screen_layout.dart';
import 'director_group_detail_screen.dart';
import 'widgets/director_group_form_dialog.dart';

class DirectorGroupsScreen extends StatefulWidget {
  const DirectorGroupsScreen({super.key});

  @override
  State<DirectorGroupsScreen> createState() => DirectorGroupsScreenState();
}

class DirectorGroupsScreenState extends State<DirectorGroupsScreen> {
  late Future<List<DirectorGroupModel>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
  }

  void reload({DirectorGroupModel? saved}) {
    setState(() {
      _groupsFuture = _fetchGroups(saved: saved);
    });
  }

  Future<List<DirectorGroupModel>> _fetchGroups({
    DirectorGroupModel? saved,
  }) async {
    final groups = await TeacherApi.getDirectorGroups(refresh: true);
    if (saved == null) return groups;

    return groups
        .map(
          (group) => group.groupNo == saved.groupNo
              ? saved.copyWith(
                  childCount: group.childCount,
                  teacherCount: group.teacherCount,
                  ageMinYr: saved.ageMinYr ?? group.ageMinYr,
                  ageMaxYr: saved.ageMaxYr ?? group.ageMaxYr,
                )
              : group,
        )
        .toList();
  }

  Future<void> _openGroup(DirectorGroupModel group) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DirectorGroupDetailScreen(group: group),
      ),
    );
    if (changed == true) reload();
  }

  Future<void> _addGroup() async {
    final form = await showDialog<DirectorGroupFormModel>(
      context: context,
      builder: (_) => const DirectorGroupFormDialog(),
    );
    if (form == null || !mounted) return;

    try {
      final created = await TeacherApi.createDirectorGroup(form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guruh qo‘shildi.')),
      );
      reload(saved: created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
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
      reload(saved: updated);
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
        content: Text(
          '“${group.groupName}” o‘chirilsinmi?\n\n'
          'Guruhda bola yoki o‘qituvchi bo‘lsa, avval ularni boshqa guruhga ko‘chiring.',
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guruh olib tashlandi.')),
      );
      reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'director-groups-fab',
        onPressed: _addGroup,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yangi guruh'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<DirectorGroupModel>>(
          future: _groupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Guruhlarni yuklab bo‘lmadi.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: reload,
                        child: const Text('Qayta urinish'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final groups = snapshot.data ?? [];

            return TabListScreenLayout(
              title: 'Guruhlar',
              subtitle:
                  'Guruhni oching — bolalar, o‘qituvchilar va guruh e’lonlari shu yerda. Tahrirlash faqat tugma orqali.',
              listPadding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              body: RefreshIndicator(
                onRefresh: () async => reload(),
                color: AppColors.primary,
                child: groups.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Hali guruh yo‘q. “Yangi guruh” tugmasini bosing.',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                        itemCount: groups.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return _GroupCard(
                            group: group,
                            onOpen: () => _openGroup(group),
                            onEdit: () => _editGroup(group),
                            onDelete: () => _deleteGroup(group),
                          );
                        },
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final DirectorGroupModel group;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(group.ageRangeLabel, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      '${group.childCount} bola · ${group.teacherCount} o‘qituvchi',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tahrirlash',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Olib tashlash')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
