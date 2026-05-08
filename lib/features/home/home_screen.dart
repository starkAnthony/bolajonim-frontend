import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '/../features/home/presentation/screens/attendance_screen.dart';
import '/../features/home/presentation/screens/meal_screen.dart';
import '/../features/home/presentation/screens/announcements_screen.dart';
import '/../features/home/presentation/screens/report_screen.dart';
import '/../features/home/presentation/screens/schedule_screen.dart';
import '/../features/home/presentation/screens/gallery_screen.dart';
import '/../features/home/presentation/screens/pickup_screen.dart';
import '/../features/home/data/mock_announcement_data.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;

  const HomeScreen({super.key, required this.onOpenProfile});

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: title)),
    );
  }

  void _openAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
    );
  }

  AnnouncementItem _getLatestAnnouncement() {
    final announcements =
        dummyAnnouncements.where((e) => e.type == 'announcement').toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final importantAnnouncements = announcements
        .where((e) => e.isImportant)
        .toList();

    if (importantAnnouncements.isNotEmpty) {
      return importantAnnouncements.first;
    }

    return announcements.first;
  }

  AnnouncementItem? _getUpcomingEvent() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final events =
        dummyAnnouncements
            .where(
              (e) =>
                  e.type == 'event' &&
                  e.eventDate != null &&
                  !DateTime(
                    e.eventDate!.year,
                    e.eventDate!.month,
                    e.eventDate!.day,
                  ).isBefore(today),
            )
            .toList()
          ..sort((a, b) => a.eventDate!.compareTo(b.eventDate!));

    if (events.isEmpty) return null;
    return events.first;
  }

  @override
  Widget build(BuildContext context) {
    final latestAnnouncement = _getLatestAnnouncement();
    final upcomingEvent = _getUpcomingEvent();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _HomeHeader(
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _ChildSummaryCard(onTap: onOpenProfile),
            const SizedBox(height: 12),
            const _TodayReportCard(),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _QuickActionCard(
                  title: 'Galereya',
                  subtitle: 'Rasmlar va videolar',
                  icon: Icons.photo_library_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GalleryScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  title: 'Taomnoma',
                  subtitle: 'Bugungi ovqatlar',
                  icon: Icons.restaurant_menu_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MealScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  title: 'Davomat',
                  subtitle: 'Kelish / ketish',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: () => _openAttendance(context),
                ),
                _QuickActionCard(
                  title: 'Olib ketish',
                  subtitle: 'Kim olib ketadi',
                  icon: Icons.directions_walk_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PickupScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  title: 'Jadval',
                  subtitle: 'Kun tartibi',
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  title: 'E’lonlar',
                  subtitle: 'Muhim xabarlar',
                  icon: Icons.campaign_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnnouncementsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AnnouncementCard(
              item: latestAnnouncement,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AnnouncementDetailScreen(item: latestAnnouncement),
                  ),
                );
              },
            ),
            if (upcomingEvent != null) ...[
              const SizedBox(height: 12),
              _UpcomingEventWideCard(
                item: upcomingEvent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AnnouncementDetailScreen(item: upcomingEvent),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const _HomeHeader({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assalomu alaykum 👋', style: AppTextStyles.bodyMedium),
              SizedBox(height: 6),
              Text('Bolajonim', style: AppTextStyles.headlineMedium),
              SizedBox(height: 4),
              Text(
                'Bugungi yangiliklarni ko‘rib chiqing',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
                Positioned(
                  top: 13,
                  right: 13,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ChildSummaryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.child_care, size: 30, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salih',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rainbow bog‘chasi • Kichik guruh',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayReportCard extends StatelessWidget {
  const _TodayReportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Bugungi hisobot', style: AppTextStyles.titleLarge),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Bugun bolalar rasm chizishdi, qo‘shiq aytishdi va ochiq havoda o‘ynashdi.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const Spacer(),
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementItem item;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.item, required this.onTap});

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF9F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('So‘nggi e’lon', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    item.preview,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(item.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingEventWideCard extends StatelessWidget {
  final AnnouncementItem item;
  final VoidCallback onTap;

  const _UpcomingEventWideCard({required this.item, required this.onTap});

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFEFF9F6),
              child: Icon(
                Icons.event_available_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yaqin tadbir', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(item.title, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    item.eventDate != null ? _formatDate(item.eventDate!) : '',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: Text('$title sahifasi', style: AppTextStyles.headlineMedium),
      ),
    );
  }
}
