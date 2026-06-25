import 'package:flutter/material.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/models/child_model.dart';
import '../../../core/models/home_model.dart';
import '../../../core/models/today_report_summary.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/child_switcher_sheet.dart';
import '/../features/home/presentation/screens/attendance_screen.dart';
import '/../features/home/presentation/screens/meal_screen.dart';
import '/../features/home/presentation/screens/announcements_screen.dart';
import '/../features/home/presentation/screens/parent_report_detail_screen.dart';
import '/../features/home/presentation/screens/report_screen.dart';
import '/../features/home/presentation/screens/schedule_screen.dart';
import '/../features/home/presentation/screens/gallery_screen.dart';
import '/../features/home/presentation/screens/pickup_screen.dart';
import '../../../core/models/announcement_item.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final String? selectedChildNo;
  final List<ChildModel> children;
  final ValueChanged<String>? onChildSelected;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    this.selectedChildNo,
    this.children = const [],
    this.onChildSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeModel> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHome();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedChildNo != widget.selectedChildNo) {
      setState(() => _homeFuture = _loadHome());
    }
  }

  Future<HomeModel> _loadHome() {
    return BolajonimApi.getHome(childNo: widget.selectedChildNo);
  }

  TodayReportSummary? _resolveTodayReport(HomeModel home) {
    if (home.todayReport != null) return home.todayReport;
    final preview = home.todayReportPreview?.trim();
    if (preview == null || preview.isEmpty) return null;
    return TodayReportSummary(
      childNo: home.child?.childNo ?? '',
      previewText: preview,
    );
  }

  void _openChildSwitcher(BuildContext context) {
    if (widget.children.length < 2 || widget.onChildSelected == null) return;

    showChildSwitcherSheet(
      context: context,
      children: widget.children,
      selectedChildNo: widget.selectedChildNo,
      onSelected: widget.onChildSelected!,
    );
  }

  void _openAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeModel>(
      future: _homeFuture,
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
                child: Text(
                  'Ma\'lumotlarni yuklab bo\'lmadi.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final home = snapshot.data!;
        final latestAnnouncement = _mapAnnouncement(home.latestAnnouncement);
        final upcomingEvent = _mapAnnouncement(home.upcomingEvent);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _HomeTopBar(
                  childName: home.child?.childName ?? 'Farzand',
                  photoUrl: BolajonimApi.resolveMediaUrl(home.child?.photoUrl),
                  subtitle: home.child?.displaySubtitle.isNotEmpty == true
                      ? home.child!.displaySubtitle
                      : null,
                  onChildTap: widget.onOpenProfile,
                  onSwitchTap: widget.children.length > 1
                      ? () => _openChildSwitcher(context)
                      : null,
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _TodayReportCard(
                  report: _resolveTodayReport(home),
                  childNo: home.child?.childNo,
                ),
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
                          MaterialPageRoute(
                            builder: (_) => const GalleryScreen(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const ScheduleScreen(),
                          ),
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
                            builder: (_) => AnnouncementsScreen(
                              childNo: widget.selectedChildNo,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (latestAnnouncement != null) ...[
                  const SizedBox(height: 12),
                  _AnnouncementCard(
                    item: latestAnnouncement,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementDetailScreen(
                            item: latestAnnouncement,
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
      },
    );
  }

  AnnouncementItem? _mapAnnouncement(AnnouncementModel? model) {
    if (model == null) return null;
    return AnnouncementItem.fromModel(model);
  }
}

class _HomeTopBar extends StatelessWidget {
  final String childName;
  final String? photoUrl;
  final String? subtitle;
  final VoidCallback onChildTap;
  final VoidCallback? onSwitchTap;
  final VoidCallback onNotificationTap;

  const _HomeTopBar({
    required this.childName,
    this.photoUrl,
    this.subtitle,
    required this.onChildTap,
    this.onSwitchTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onChildTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      _ChildAvatar(photoUrl: photoUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              childName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onSwitchTap != null) ...[
            _TopBarIconButton(
              icon: Icons.swap_horiz_rounded,
              onTap: onSwitchTap!,
              tooltip: 'Farzandni almashtirish',
            ),
            const SizedBox(width: 6),
          ],
          _TopBarIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onNotificationTap,
            showBadge: true,
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool showBadge;

  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FA),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.textPrimary),
              if (showBadge)
                const Positioned(
                  top: 11,
                  right: 11,
                  child: CircleAvatar(
                    radius: 3.5,
                    backgroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ChildAvatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFF8F6),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : const Icon(
              Icons.child_care_rounded,
              size: 24,
              color: AppColors.primary,
            ),
    );
  }
}

class _TodayReportCard extends StatelessWidget {
  final TodayReportSummary? report;
  final String? childNo;

  const _TodayReportCard({
    required this.report,
    required this.childNo,
  });

  void _openDetail(BuildContext context) {
    final summary = report;
    if (summary == null || !summary.hasContent) return;

    final reportNo = summary.reportNo;
    final resolvedChildNo = summary.childNo.isNotEmpty
        ? summary.childNo
        : childNo ?? '';

    if (reportNo != null && resolvedChildNo.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ParentReportDetailScreen(
            reportNo: reportNo,
            childNo: resolvedChildNo,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = report;
    final hasContent = summary?.hasContent == true;
    final isHealth = summary?.reportType.toLowerCase() == 'health';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: hasContent ? () => _openDetail(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bugungi hisobot',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                  if (hasContent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        summary!.typeLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (!hasContent)
                Text(
                  'Bugun uchun hisobot hali kiritilmagan.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else if (isHealth && summary!.metricRows.isNotEmpty)
                ...summary.metricRows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.label,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            row.value,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  summary!.previewText!,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              if (hasContent) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'Batafsil ko\'rish',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
