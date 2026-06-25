import 'package:flutter/material.dart';

import '../../../core/models/staff_profile_model.dart';
import '../../../core/models/staff_personal_profile_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/tab_list_screen_layout.dart';
import '../../auth/presentation/start_screen.dart';
import '../../profile/app_settings_screen.dart';
import 'staff_personal_profile_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  late Future<StaffProfileModel> _profileFuture;
  late Future<StaffPersonalProfileModel> _personalFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = TeacherApi.getProfile();
    _personalFuture = TeacherApi.getStaffPersonalProfile();
  }

  void _reload() {
    setState(() {
      _profileFuture = TeacherApi.getProfile();
      _personalFuture = TeacherApi.getStaffPersonalProfile();
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Chiqish',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Akkauntingizdan chiqmoqchimisiz?',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Bekor qilish',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Chiqish',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartScreen()),
      (route) => false,
    );
  }

  String _roleLabel(String roleCode) {
    switch (roleCode.toUpperCase()) {
      case 'DIRECTOR':
        return 'Direktor';
      case 'TEACHER':
        return 'O‘qituvchi';
      default:
        return roleCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<StaffProfileModel>(
          future: _profileFuture,
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
              );
            }

            final profile = snapshot.data!;

            return TabListScreenLayout(
              title: 'Profil',
              body: RefreshIndicator(
                onRefresh: () async => _reload(),
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    FutureBuilder<StaffPersonalProfileModel>(
                      future: _personalFuture,
                      builder: (context, personalSnapshot) {
                        final photoUrl = personalSnapshot.hasData
                            ? BolajonimApi.resolveMediaUrl(
                                personalSnapshot.data!.photoUrl,
                              )
                            : null;
                        return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFEFF8F6),
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _roleLabel(profile.roleCode),
                                style: AppTextStyles.bodySmall,
                              ),
                              if (profile.groupName != null &&
                                  profile.groupName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  profile.groupName!,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                              if (profile.kgName != null &&
                                  profile.kgName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  profile.kgName!,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                        );
                      },
                    ),
                  if (profile.inviteCode != null &&
                      profile.inviteCode!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.vpn_key_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Taklif kodi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  profile.inviteCode!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (profile.isDirector) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.space_dashboard_rounded,
                              color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'O‘qituvchi va bolalarni Bosh sahifasidan boshqaring.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (!profile.permChildEdit &&
                      !profile.permReportEdit &&
                      !profile.permAttendanceEdit &&
                      !profile.permEventEdit) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFFB7791F)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Amallar uchun direktordan ruxsat kerak.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF744210),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Ruxsatlar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PermissionChip(
                      label: 'Bola ma’lumotlari',
                      enabled: profile.permChildEdit,
                    ),
                    _PermissionChip(
                      label: 'Kunlik hisobotlar',
                      enabled: profile.permReportEdit,
                    ),
                    _PermissionChip(
                      label: 'Davomat',
                      enabled: profile.permAttendanceEdit,
                    ),
                    _PermissionChip(
                      label: 'Tadbirlar',
                      enabled: profile.permEventEdit,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.badge_outlined,
                    title: 'Shaxsiy ma’lumotlar',
                    subtitle: 'Rasm, laqab, yosh, manzil',
                    onTap: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffPersonalProfileScreen(),
                        ),
                      );
                      if (updated == true) _reload();
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.settings_outlined,
                    title: 'Sozlamalar',
                    subtitle: 'Til, bildirishnomalar va ilova sozlamalari',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Chiqish',
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
              ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  final bool enabled;

  const _PermissionChip({
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              enabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
              color: enabled ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
