import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'director_children_screen.dart';
import 'director_staff_screen.dart';
import '../../../core/models/director_dashboard_model.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DirectorHomeScreen extends StatefulWidget {
  final VoidCallback? onOpenGroups;
  final VoidCallback? onOpenChildren;
  final VoidCallback? onOpenStaff;

  const DirectorHomeScreen({
    super.key,
    this.onOpenGroups,
    this.onOpenChildren,
    this.onOpenStaff,
  });

  @override
  State<DirectorHomeScreen> createState() => _DirectorHomeScreenState();
}

class _DirectorHomeScreenState extends State<DirectorHomeScreen> {
  late Future<DirectorDashboardModel> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = TeacherApi.getDirectorDashboard();
  }

  void _reload() {
    setState(() {
      _dashboardFuture = TeacherApi.getDirectorDashboard();
    });
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Taklif kodi nusxalandi.')),
    );
  }

  Future<void> _openStaff() async {
    if (widget.onOpenStaff != null) {
      widget.onOpenStaff!();
      _reload();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DirectorStaffScreen()),
    );
    _reload();
  }

  Future<void> _openChildren() async {
    if (widget.onOpenChildren != null) {
      widget.onOpenChildren!();
      _reload();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DirectorChildrenScreen()),
    );
    _reload();
  }

  void _openGroups() {
    widget.onOpenGroups?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DirectorDashboardModel>(
      future: _dashboardFuture,
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

        final dashboard = snapshot.data!;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  const Text(
                    'Boshqaruv paneli',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bog‘cha holati. Ro‘yxat uchun kartani bosing.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  _DirectorSummaryCard(
                    kgName: dashboard.kgName,
                    inviteCode: dashboard.inviteCode,
                    onCopyInvite: () => _copyInviteCode(dashboard.inviteCode),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _HubStatCard(
                          title: 'O‘qituvchilar',
                          value: '${dashboard.teacherCount}',
                          icon: Icons.school_outlined,
                          accent: const Color(0xFF5BBAD5),
                          subtitle: 'Ro‘yxat va ruxsatlar',
                          onTap: _openStaff,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HubStatCard(
                          title: 'Bolalar',
                          value: '${dashboard.childCount}',
                          icon: Icons.child_care_outlined,
                          accent: const Color(0xFF4CD3A6),
                          subtitle: 'Qo‘shish va tahrirlash',
                          onTap: _openChildren,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HubStatCard(
                          title: 'Guruhlar',
                          value: '${dashboard.groupCount}',
                          icon: Icons.groups_2_outlined,
                          accent: const Color(0xFF8B7CF6),
                          subtitle: 'Yaratish va tahrirlash',
                          onTap: _openGroups,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          title: 'Xabarlar',
                          value: '${dashboard.unreadMessages}',
                          icon: Icons.markunread_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'So‘nggi e’lon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dashboard.latestAnnouncement?.isNotEmpty == true
                          ? dashboard.latestAnnouncement!
                          : 'Hozircha e’lonlar yo‘q.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DirectorSummaryCard extends StatelessWidget {
  final String kgName;
  final String inviteCode;
  final VoidCallback onCopyInvite;

  const _DirectorSummaryCard({
    required this.kgName,
    required this.inviteCode,
    required this.onCopyInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF5BBAD5), Color(0xFF4CD3A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kgName,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'O‘qituvchilar uchun taklif kodi',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onCopyInvite,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        inviteCode.isNotEmpty ? inviteCode : '—',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.copy_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nusxalash uchun bosing',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _HubStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _HubStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accent, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
