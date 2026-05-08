import 'package:flutter/material.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;

  final Map<DateTime, DailyScheduleData> _scheduleMap = {
    _dateOnly(DateTime(2026, 4, 20)): DailyScheduleData(
      teacherNote:
          'Bugun bolalar bilan rasm chizish va ochiq havoda harakatli o‘yinlar rejalashtirilgan.',
      items: const [
        ScheduleItem(
          time: '08:30',
          title: 'Bolalarni kutib olish',
          subtitle: 'Erkin o‘yin va salomlashish',
          type: ScheduleItemType.arrival,
        ),
        ScheduleItem(
          time: '09:00',
          title: 'Ertalabki badantarbiya',
          subtitle: 'Yengil mashqlar va harakatli o‘yinlar',
          type: ScheduleItemType.exercise,
        ),
        ScheduleItem(
          time: '09:30',
          title: 'Ertalabki tamaddi',
          subtitle: 'Yengil ovqatlanish va suv ichish',
          type: ScheduleItemType.meal,
        ),
        ScheduleItem(
          time: '10:15',
          title: 'Asosiy mashg‘ulot',
          subtitle: 'Rasm chizish va ranglarni o‘rganish',
          type: ScheduleItemType.study,
        ),
        ScheduleItem(
          time: '11:20',
          title: 'Ochiq havo',
          subtitle: 'Maydonchada o‘yin va sayr',
          type: ScheduleItemType.outdoor,
        ),
        ScheduleItem(
          time: '12:10',
          title: 'Tushlik',
          subtitle: 'Asosiy ovqatlanish va dam olishga tayyorgarlik',
          type: ScheduleItemType.meal,
        ),
        ScheduleItem(
          time: '13:00',
          title: 'Tushki uyqu',
          subtitle: 'Dam olish va sokin vaqt',
          type: ScheduleItemType.sleep,
        ),
        ScheduleItem(
          time: '15:20',
          title: 'Uyg‘onish va tamaddi',
          subtitle: 'Yengil tamaddi va suv ichish',
          type: ScheduleItemType.meal,
        ),
        ScheduleItem(
          time: '16:00',
          title: 'Erkin o‘yin',
          subtitle: 'Konstruktor, kitob va muloqot',
          type: ScheduleItemType.play,
        ),
        ScheduleItem(
          time: '17:10',
          title: 'Uyga tayyorgarlik',
          subtitle: 'Ota-onalarni kutish',
          type: ScheduleItemType.pickup,
        ),
      ],
    ),
    _dateOnly(DateTime(2026, 4, 19)): DailyScheduleData(
      teacherNote:
          'Bugungi kun sokin faoliyatlar va hikoya tinglash bilan o‘tadi.',
      items: const [
        ScheduleItem(
          time: '08:30',
          title: 'Bolalarni kutib olish',
          subtitle: 'Salomlashish va erkin o‘yin',
          type: ScheduleItemType.arrival,
        ),
        ScheduleItem(
          time: '09:15',
          title: 'Ertalabki davra',
          subtitle: 'Ob-havo va kayfiyat haqida suhbat',
          type: ScheduleItemType.study,
        ),
        ScheduleItem(
          time: '09:40',
          title: 'Tamaddi',
          subtitle: 'Yengil ovqatlanish',
          type: ScheduleItemType.meal,
        ),
        ScheduleItem(
          time: '10:30',
          title: 'Hikoya va kitob vaqti',
          subtitle: 'Rasmlarni ko‘rish va savol-javob',
          type: ScheduleItemType.story,
        ),
        ScheduleItem(
          time: '11:30',
          title: 'Ochiq havo',
          subtitle: 'Sayr va qum o‘yinlari',
          type: ScheduleItemType.outdoor,
        ),
        ScheduleItem(
          time: '12:10',
          title: 'Tushlik',
          subtitle: 'Asosiy ovqatlanish',
          type: ScheduleItemType.meal,
        ),
        ScheduleItem(
          time: '13:00',
          title: 'Dam olish',
          subtitle: 'Tinch vaqt va uyqu',
          type: ScheduleItemType.sleep,
        ),
        ScheduleItem(
          time: '15:30',
          title: 'Erkin o‘yin',
          subtitle: 'Do‘stlar bilan o‘yin',
          type: ScheduleItemType.play,
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _goPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goNextDay() {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    final today = _dateOnly(DateTime.now());

    if (nextDay.isAfter(today)) return;

    setState(() {
      _selectedDate = nextDay;
    });
  }

  void _goToday() {
    setState(() {
      _selectedDate = _dateOnly(DateTime.now());
    });
  }

  String _dateLabel(DateTime date) {
    const weekdays = [
      '',
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];

    const months = [
      '',
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avgust',
      'sentabr',
      'oktabr',
      'noyabr',
      'dekabr',
    ];

    return '${weekdays[date.weekday]}, ${date.day}-${months[date.month]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final data = _scheduleMap[_selectedDate];
    final isToday = _selectedDate == _dateOnly(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Jadval',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _ScheduleHeaderCard(
              childName: 'SALIH (Sali)',
              groupName: 'Kichik guruh',
            ),
            const SizedBox(height: 12),
            _DateNavigatorCard(
              dateLabel: _dateLabel(_selectedDate),
              isToday: isToday,
              onPrevious: _goPreviousDay,
              onNext: _goNextDay,
              onToday: _goToday,
            ),
            const SizedBox(height: 12),
            if (data == null)
              _EmptyScheduleCard(dateLabel: _dateLabel(_selectedDate))
            else ...[
              _TeacherNoteCard(note: data.teacherNote),
              const SizedBox(height: 12),
              _TimelineCard(items: data.items, isToday: isToday),
            ],
          ],
        ),
      ),
    );
  }
}

class DailyScheduleData {
  final String teacherNote;
  final List<ScheduleItem> items;

  const DailyScheduleData({required this.teacherNote, required this.items});
}

class ScheduleItem {
  final String time;
  final String title;
  final String subtitle;
  final ScheduleItemType type;

  const ScheduleItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

enum ScheduleItemType {
  arrival,
  exercise,
  meal,
  study,
  outdoor,
  sleep,
  play,
  pickup,
  story,
}

enum ScheduleProgress { done, current, upcoming }

class _ScheduleHeaderCard extends StatelessWidget {
  final String childName;
  final String groupName;

  const _ScheduleHeaderCard({required this.childName, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEFF9F6),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(groupName, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateNavigatorCard extends StatelessWidget {
  final String dateLabel;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _DateNavigatorCard({
    required this.dateLabel,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  dateLabel,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isToday ? 'Bugungi jadval' : 'Tanlangan sana',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
          const SizedBox(width: 12),
          InkWell(
            onTap: onToday,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary),
                color: Colors.white,
              ),
              child: const Text(
                'Bugun',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TeacherNoteCard extends StatelessWidget {
  final String note;

  const _TeacherNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.sticky_note_2_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tarbiyachi eslatmasi',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(note, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<ScheduleItem> items;
  final bool isToday;

  const _TimelineCard({required this.items, required this.isToday});

  ScheduleProgress _getProgress(
    int index,
    List<ScheduleItem> items,
    bool isToday,
  ) {
    if (!isToday) return ScheduleProgress.done;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    final current = items[index];
    final currentMinutes = _toMinutes(current.time);

    int? nextMinutes;

    if (index < items.length - 1) {
      nextMinutes = _toMinutes(items[index + 1].time);
    }

    if (nowMinutes < currentMinutes) {
      return ScheduleProgress.upcoming;
    }

    if (nextMinutes == null) {
      return ScheduleProgress.current;
    }

    if (nowMinutes >= currentMinutes && nowMinutes < nextMinutes) {
      return ScheduleProgress.current;
    }

    return ScheduleProgress.done;
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final progress = _getProgress(index, items, isToday);
          return _TimelineItemWidget(
            item: item,
            progress: progress,
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }
}

class _TimelineItemWidget extends StatelessWidget {
  final ScheduleItem item;
  final ScheduleProgress progress;
  final bool isLast;

  const _TimelineItemWidget({
    required this.item,
    required this.progress,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final meta = ScheduleItemMeta.fromType(item.type);

    final Color dotColor;
    final Color lineColor;
    final Color cardColor;
    final Color badgeColor;
    final Color badgeTextColor;
    final String badgeText;

    switch (progress) {
      case ScheduleProgress.done:
        dotColor = const Color(0xFFB8C1CC);
        lineColor = const Color(0xFFDCE3EA);
        cardColor = const Color(0xFFF8FAFC);
        badgeColor = const Color(0xFFEDEFF3);
        badgeTextColor = AppColors.textSecondary;
        badgeText = 'Tugagan';
        break;
      case ScheduleProgress.current:
        dotColor = AppColors.primary;
        lineColor = const Color(0xFFDCE3EA);
        cardColor = const Color(0xFFEFF9F6);
        badgeColor = AppColors.primary;
        badgeTextColor = Colors.white;
        badgeText = 'Hozir';
        break;
      case ScheduleProgress.upcoming:
        dotColor = meta.iconColor;
        lineColor = const Color(0xFFDCE3EA);
        cardColor = Colors.white;
        badgeColor = meta.softBackground;
        badgeTextColor = meta.iconColor;
        badgeText = 'Kutilmoqda';
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 66,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              item.time,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast) Container(width: 2, height: 88, color: lineColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 4 : 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAEFF4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: meta.softBackground,
                    child: Icon(meta.icon, color: meta.iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTextStyles.titleLarge),
                        const SizedBox(height: 6),
                        Text(item.subtitle, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyScheduleCard extends StatelessWidget {
  final String dateLabel;

  const _EmptyScheduleCard({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: AppTextStyles.titleLarge),
          const SizedBox(height: 10),
          const Text(
            'Bu sana uchun jadval ma’lumoti yo‘q.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class ScheduleItemMeta {
  final IconData icon;
  final Color iconColor;
  final Color softBackground;

  const ScheduleItemMeta({
    required this.icon,
    required this.iconColor,
    required this.softBackground,
  });

  factory ScheduleItemMeta.fromType(ScheduleItemType type) {
    switch (type) {
      case ScheduleItemType.arrival:
        return const ScheduleItemMeta(
          icon: Icons.login_rounded,
          iconColor: Color(0xFF4A90E2),
          softBackground: Color(0xFFEDF4FF),
        );
      case ScheduleItemType.exercise:
        return const ScheduleItemMeta(
          icon: Icons.directions_run_rounded,
          iconColor: Color(0xFFF2A93B),
          softBackground: Color(0xFFFFF7E9),
        );
      case ScheduleItemType.meal:
        return const ScheduleItemMeta(
          icon: Icons.restaurant_menu_rounded,
          iconColor: AppColors.primary,
          softBackground: Color(0xFFEAFBF8),
        );
      case ScheduleItemType.study:
        return const ScheduleItemMeta(
          icon: Icons.menu_book_rounded,
          iconColor: Color(0xFF7E57C2),
          softBackground: Color(0xFFF3EEFF),
        );
      case ScheduleItemType.outdoor:
        return const ScheduleItemMeta(
          icon: Icons.park_outlined,
          iconColor: Color(0xFF4CAF50),
          softBackground: Color(0xFFEFF8EE),
        );
      case ScheduleItemType.sleep:
        return const ScheduleItemMeta(
          icon: Icons.nightlight_round,
          iconColor: Color(0xFF5C6BC0),
          softBackground: Color(0xFFEEF1FF),
        );
      case ScheduleItemType.play:
        return const ScheduleItemMeta(
          icon: Icons.toys_outlined,
          iconColor: Color(0xFFFF7A59),
          softBackground: Color(0xFFFFEFEA),
        );
      case ScheduleItemType.pickup:
        return const ScheduleItemMeta(
          icon: Icons.family_restroom_outlined,
          iconColor: Color(0xFF8D6E63),
          softBackground: Color(0xFFF5EFEC),
        );
      case ScheduleItemType.story:
        return const ScheduleItemMeta(
          icon: Icons.auto_stories_outlined,
          iconColor: Color(0xFF26A69A),
          softBackground: Color(0xFFEAF9F7),
        );
    }
  }
}
