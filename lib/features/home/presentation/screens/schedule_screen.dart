import 'package:flutter/material.dart';
import '/../../core/models/meal_model.dart';
import '/../../core/models/schedule_model.dart';
import '/../../core/services/bolajonim_api.dart';
import '/../../core/services/selected_child_service.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  DailyScheduleData? _scheduleData;
  bool _isLoading = true;
  String _childName = 'Farzand';
  String _groupName = '-';

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final children = await BolajonimApi.getChildren();
      if (children.isEmpty) {
        if (!mounted) return;
        setState(() {
          _scheduleData = null;
          _isLoading = false;
        });
        return;
      }

      final childNo = await SelectedChildService.resolveSelection(children);
      final child = children.firstWhere(
        (item) => item.childNo == childNo,
        orElse: () => children.first,
      );

      final schedule = await BolajonimApi.getSchedule(
        childNo: child.childNo,
        scheduleDt: BolajonimDateParser.toYyyyMmDd(_selectedDate),
      );

      if (!mounted) return;
      setState(() {
        _childName = child.childName;
        _groupName = child.groupName ?? '-';
        _scheduleData = _mapSchedule(schedule);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scheduleData = null;
        _isLoading = false;
      });
    }
  }

  DailyScheduleData? _mapSchedule(ScheduleDayModel schedule) {
    if (schedule.items.isEmpty) return null;

    return DailyScheduleData(
      teacherNote: schedule.teacherNote,
      items: schedule.items
          .map(
            (item) => ScheduleItem(
              time: item.startTime,
              title: item.title,
              subtitle: item.subtitle,
              type: _mapScheduleType(item.itemType),
            ),
          )
          .toList(),
    );
  }

  ScheduleItemType _mapScheduleType(String type) {
    switch (type.toLowerCase()) {
      case 'arrival':
        return ScheduleItemType.arrival;
      case 'exercise':
        return ScheduleItemType.exercise;
      case 'meal':
        return ScheduleItemType.meal;
      case 'outdoor':
        return ScheduleItemType.outdoor;
      case 'sleep':
        return ScheduleItemType.sleep;
      case 'play':
        return ScheduleItemType.play;
      case 'pickup':
        return ScheduleItemType.pickup;
      case 'story':
        return ScheduleItemType.story;
      default:
        return ScheduleItemType.study;
    }
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _goPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadSchedule();
  }

  void _goNextDay() {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    final today = _dateOnly(DateTime.now());

    if (nextDay.isAfter(today)) return;

    setState(() {
      _selectedDate = nextDay;
    });
    _loadSchedule();
  }

  void _goToday() {
    setState(() {
      _selectedDate = _dateOnly(DateTime.now());
    });
    _loadSchedule();
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
    final data = _scheduleData;
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ScheduleHeaderCard(
                    childName: _childName,
                    groupName: _groupName,
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
                    if (data.teacherNote.trim().isNotEmpty)
                      _TeacherNoteCard(note: data.teacherNote),
                    if (data.teacherNote.trim().isNotEmpty)
                      const SizedBox(height: 12),
                    const _SchedulePlanInfoCard(),
                    const SizedBox(height: 12),
                    _ScheduleListCard(items: data.items),
                  ],                ],
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

class _SchedulePlanInfoCard extends StatelessWidget {
  const _SchedulePlanInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bu rejalashtirilgan kun tartibi. Vaqt taxminiy — bolalar ehtiyojiga qarab o‘zgarishi mumkin.',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleHeaderCard extends StatelessWidget {  final String childName;
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
                  isToday ? 'Kun tartibi' : 'Tanlangan sana',
                  style: AppTextStyles.bodySmall,
                ),              ],
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

class _ScheduleListCard extends StatelessWidget {
  final List<ScheduleItem> items;

  const _ScheduleListCard({required this.items});

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
          return _ScheduleListItem(
            item: item,
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }
}

class _ScheduleListItem extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;

  const _ScheduleListItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final meta = ScheduleItemMeta.fromType(item.type);

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
                color: meta.iconColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 72, color: const Color(0xFFDCE3EA)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 4 : 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
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

class _EmptyScheduleCard extends StatelessWidget {  final String dateLabel;

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
