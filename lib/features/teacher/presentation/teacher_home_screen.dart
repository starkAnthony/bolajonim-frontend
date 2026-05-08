import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, Teacher',
                        style: AppTextStyles.headlineMedium,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Here is today’s classroom overview.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _TeacherSummaryCard(),
            const SizedBox(height: 14),

            const Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: 'Present',
                    value: '16',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Absent',
                    value: '2',
                    icon: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: 'Pending Pickup',
                    value: '5',
                    icon: Icons.access_time_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Unread Notes',
                    value: '8',
                    icon: Icons.markunread_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'Quick actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: const [
                _QuickActionCard(
                  icon: Icons.fact_check_outlined,
                  title: 'Attendance',
                  subtitle: 'Check today attendance',
                ),
                _QuickActionCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Meal Log',
                  subtitle: 'Record meals for children',
                ),
                _QuickActionCard(
                  icon: Icons.bedtime_outlined,
                  title: 'Nap Log',
                  subtitle: 'Track sleep and rest',
                ),
                _QuickActionCard(
                  icon: Icons.photo_library_outlined,
                  title: 'Photos',
                  subtitle: 'Upload class activity photos',
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'Today schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            const _ScheduleTile(
              time: '09:00',
              title: 'Morning attendance',
              subtitle: 'Check arrivals and parent notes',
            ),
            const SizedBox(height: 10),
            const _ScheduleTile(
              time: '11:30',
              title: 'Lunch time',
              subtitle: 'Meal tracking and allergy check',
            ),
            const SizedBox(height: 10),
            const _ScheduleTile(
              time: '13:00',
              title: 'Nap time',
              subtitle: 'Sleep monitoring',
            ),
            const SizedBox(height: 10),
            const _ScheduleTile(
              time: '16:30',
              title: 'Pickup time',
              subtitle: 'Guardian confirmation and handoff',
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherSummaryCard extends StatelessWidget {
  const _TeacherSummaryCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rainbow Kindergarten',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Small Group A',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '18 children • 2 teachers • 1 assistant',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          Icon(icon, color: AppColors.primary, size: 26),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;

  const _ScheduleTile({
    required this.time,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
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
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
