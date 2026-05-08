import 'package:flutter/material.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  final Map<DateTime, AttendanceRecord> _attendanceMap = {
    _dateOnly(DateTime(2026, 4, 1)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:41',
      leavingTime: '17:18',
      pickupPerson: 'Otasi',
      note: 'Bugun ertalab yaxshi kayfiyatda keldi.',
    ),
    _dateOnly(DateTime(2026, 4, 2)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:39',
      leavingTime: '17:24',
      pickupPerson: 'Otasi',
      note: 'Mashg‘ulotlarda faol qatnashdi.',
    ),
    _dateOnly(DateTime(2026, 4, 3)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:45',
      leavingTime: '17:11',
      pickupPerson: 'Onasi',
      note: 'Rasm chizish mashg‘ulotida faol bo‘ldi.',
    ),
    _dateOnly(DateTime(2026, 4, 6)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:47',
      leavingTime: '17:09',
      pickupPerson: 'Otasi',
      note: 'Bugun do‘stlari bilan yaxshi o‘ynadi.',
    ),
    _dateOnly(DateTime(2026, 4, 7)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:44',
      leavingTime: '17:22',
      pickupPerson: 'Onasi',
      note: 'Qo‘shiq aytish faoliyatida qatnashdi.',
    ),
    _dateOnly(DateTime(2026, 4, 8)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:42',
      leavingTime: '17:19',
      pickupPerson: 'Otasi',
      note: 'Tarbiyachi ko‘rsatmalarini yaxshi bajardi.',
    ),
    _dateOnly(DateTime(2026, 4, 9)): const AttendanceRecord(
      status: AttendanceStatus.excused,
      note: 'Oilaviy sabab bilan kelmadi.',
    ),
    _dateOnly(DateTime(2026, 4, 10)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:40',
      leavingTime: '17:20',
      pickupPerson: 'Otasi',
      note: 'Bugun ochiq havoda o‘yinlar bo‘ldi.',
    ),
    _dateOnly(DateTime(2026, 4, 13)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:43',
      leavingTime: '17:16',
      pickupPerson: 'Onasi',
      note: 'Yaxshi ovqatlandi.',
    ),
    _dateOnly(DateTime(2026, 4, 14)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:38',
      leavingTime: '17:28',
      pickupPerson: 'Otasi',
      note: 'Kun davomida faol bo‘ldi.',
    ),
    _dateOnly(DateTime(2026, 4, 15)): const AttendanceRecord(
      status: AttendanceStatus.sick,
      note: 'Sog‘ligi sabab kelmadi.',
    ),
    _dateOnly(DateTime(2026, 4, 16)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:41',
      leavingTime: '17:13',
      pickupPerson: 'Otasi',
      note: 'Rangli qog‘oz bilan ishlashda qatnashdi.',
    ),
    _dateOnly(DateTime(2026, 4, 17)): const AttendanceRecord(
      status: AttendanceStatus.leftEarly,
      arrivalTime: '08:46',
      leavingTime: '14:10',
      pickupPerson: 'Onasi',
      note: 'Bugun erta olib ketildi.',
    ),
    _dateOnly(DateTime(2026, 4, 20)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:43',
      leavingTime: '17:20',
      pickupPerson: 'Otasi',
      note: 'Bugun mashg‘ulotlarda faol qatnashdi.',
    ),
    _dateOnly(DateTime(2026, 4, 21)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:37',
      leavingTime: '17:21',
      pickupPerson: 'Otasi',
      note: 'Do‘stlari bilan yaxshi muloqot qildi.',
    ),
    _dateOnly(DateTime(2026, 4, 22)): const AttendanceRecord(
      status: AttendanceStatus.absent,
      note: 'Sababsiz kelmadi.',
    ),
    _dateOnly(DateTime(2026, 4, 23)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:42',
      leavingTime: '17:14',
      pickupPerson: 'Onasi',
      note: 'Bugun o‘yin vaqtida quvnoq bo‘ldi.',
    ),
    _dateOnly(DateTime(2026, 4, 24)): const AttendanceRecord(
      status: AttendanceStatus.present,
      arrivalTime: '08:40',
      leavingTime: '17:18',
      pickupPerson: 'Otasi',
      note: 'Faoliyatlarda yaxshi qatnashdi.',
    ),
  };

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedMonth = DateTime(today.year, today.month, 1);
    _selectedDate = _isFuture(today) ? null : today;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isFuture(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final checkDate = _dateOnly(date);
    return checkDate.isAfter(today);
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);

      if (_selectedDate != null &&
          (_selectedDate!.year != _focusedMonth.year ||
              _selectedDate!.month != _focusedMonth.month)) {
        _selectedDate = null;
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);

      if (_selectedDate != null &&
          (_selectedDate!.year != _focusedMonth.year ||
              _selectedDate!.month != _focusedMonth.month)) {
        _selectedDate = null;
      }
    });
  }

  void _goToToday() {
    final today = _dateOnly(DateTime.now());
    setState(() {
      _focusedMonth = DateTime(today.year, today.month, 1);
      _selectedDate = _isFuture(today) ? null : today;
    });
  }

  List<DateTime> _buildCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final startOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    final startDate = firstDayOfMonth.subtract(Duration(days: startOffset));

    final endOffset = 6 - (lastDayOfMonth.weekday % 7);
    final endDate = lastDayOfMonth.add(Duration(days: endOffset));

    final days = <DateTime>[];
    DateTime current = startDate;

    while (!current.isAfter(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  String _monthLabel(DateTime date) {
    const monthNames = [
      '',
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return '${monthNames[date.month]} ${date.year}';
  }

  String _dateLabel(DateTime date) {
    const monthNames = [
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
    return '${date.day}-${monthNames[date.month]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _buildCalendarDays(_focusedMonth);

    AttendanceRecord? selectedRecord;
    if (_selectedDate != null && !_isFuture(_selectedDate!)) {
      selectedRecord = _attendanceMap[_dateOnly(_selectedDate!)];
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Davomat',
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
            _ChildAttendanceHeader(
              childName: 'SALIH (Sali)',
              groupName: 'Kichik guruh',
              statusText: 'Shu oyda 14 marta keldi',
            ),
            const SizedBox(height: 12),
            _MonthNavigator(
              monthLabel: _monthLabel(_focusedMonth),
              onPrevious: _goToPreviousMonth,
              onNext: _goToNextMonth,
              onToday: _goToToday,
            ),
            const SizedBox(height: 12),
            _CalendarCard(
              focusedMonth: _focusedMonth,
              days: calendarDays,
              selectedDate: _selectedDate,
              attendanceMap: _attendanceMap,
              onDateTap: (date) {
                if (_isFuture(date)) return;
                setState(() {
                  _selectedDate = _dateOnly(date);
                });
              },
            ),
            const SizedBox(height: 12),
            const _AttendanceLegendCard(),
            const SizedBox(height: 12),
            _SelectedDayDetailCard(
              selectedDate: _selectedDate,
              selectedRecord: selectedRecord,
              dateLabelBuilder: _dateLabel,
              isFutureDate: _selectedDate != null && _isFuture(_selectedDate!),
            ),
          ],
        ),
      ),
    );
  }
}

enum AttendanceStatus { present, absent, sick, excused, leftEarly }

class AttendanceRecord {
  final AttendanceStatus status;
  final String? arrivalTime;
  final String? leavingTime;
  final String? pickupPerson;
  final String? note;

  const AttendanceRecord({
    required this.status,
    this.arrivalTime,
    this.leavingTime,
    this.pickupPerson,
    this.note,
  });
}

class _ChildAttendanceHeader extends StatelessWidget {
  final String childName;
  final String groupName;
  final String statusText;

  const _ChildAttendanceHeader({
    required this.childName,
    required this.groupName,
    required this.statusText,
  });

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
            child: Icon(Icons.child_care, size: 28, color: AppColors.primary),
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
          Text(
            statusText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final String monthLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _MonthNavigator({
    required this.monthLabel,
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
          _MonthNavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: Text(
                monthLabel,
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MonthNavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
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

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

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

class _CalendarCard extends StatelessWidget {
  final DateTime focusedMonth;
  final List<DateTime> days;
  final DateTime? selectedDate;
  final Map<DateTime, AttendanceRecord> attendanceMap;
  final ValueChanged<DateTime> onDateTap;

  const _CalendarCard({
    required this.focusedMonth,
    required this.days,
    required this.selectedDate,
    required this.attendanceMap,
    required this.onDateTap,
  });

  bool _isSameDate(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isFuture(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(todayOnly);
  }

  @override
  Widget build(BuildContext context) {
    const weekLabels = ['Yak', 'Du', 'Se', 'Chor', 'Pay', 'Ju', 'Sha'];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: weekLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          GridView.builder(
            itemCount: days.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == focusedMonth.month;
              final isSelected = _isSameDate(day, selectedDate);

              final rawRecord =
                  attendanceMap[DateTime(day.year, day.month, day.day)];
              final isFuture = _isFuture(day);
              final record = isFuture ? null : rawRecord;

              return _CalendarDayCell(
                date: day,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected,
                isFuture: isFuture,
                record: record,
                onTap: isFuture ? null : () => onDateTap(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isFuture;
  final AttendanceRecord? record;
  final VoidCallback? onTap;

  const _CalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isFuture,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusMeta = record == null
        ? null
        : AttendanceStatusMeta.fromStatus(record!.status);

    Color backgroundColor = Colors.transparent;
    Color borderColor = const Color(0xFFEAEFF4);

    Color dayTextColor = isFuture
        ? const Color(0xFFD0D5DB)
        : isCurrentMonth
        ? AppColors.textPrimary
        : const Color(0xFFBFC6CE);

    if (record != null && !isSelected) {
      backgroundColor = statusMeta!.softBackground;
      borderColor = statusMeta.softBackground;
      dayTextColor = AppColors.textPrimary;
    }

    if (isSelected) {
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      dayTextColor = Colors.white;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dayTextColor,
                ),
              ),
            ),
            const Spacer(),
            if (record != null)
              Icon(
                statusMeta!.icon,
                size: 22,
                color: isSelected ? Colors.white : statusMeta.iconColor,
              ),
            if (record == null) const SizedBox(height: 22),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _AttendanceLegendCard extends StatelessWidget {
  const _AttendanceLegendCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      AttendanceStatusMeta.fromStatus(AttendanceStatus.present),
      AttendanceStatusMeta.fromStatus(AttendanceStatus.excused),
      AttendanceStatusMeta.fromStatus(AttendanceStatus.absent),
      AttendanceStatusMeta.fromStatus(AttendanceStatus.sick),
      AttendanceStatusMeta.fromStatus(AttendanceStatus.leftEarly),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items
            .map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 18, color: item.iconColor),
                    const SizedBox(width: 8),
                    Text(item.label, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SelectedDayDetailCard extends StatelessWidget {
  final DateTime? selectedDate;
  final AttendanceRecord? selectedRecord;
  final String Function(DateTime date) dateLabelBuilder;
  final bool isFutureDate;

  const _SelectedDayDetailCard({
    required this.selectedDate,
    required this.selectedRecord,
    required this.dateLabelBuilder,
    required this.isFutureDate,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text('Sanani tanlang.', style: AppTextStyles.bodyMedium),
      );
    }

    if (isFutureDate) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabelBuilder(selectedDate!),
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Kelajak sanasi uchun davomat ma’lumoti yo‘q.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (selectedRecord == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabelBuilder(selectedDate!),
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Bu sana uchun davomat ma’lumoti yo‘q.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    final meta = AttendanceStatusMeta.fromStatus(selectedRecord!.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabelBuilder(selectedDate!),
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: meta.softBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(meta.icon, size: 18, color: meta.iconColor),
                const SizedBox(width: 8),
                Text(
                  meta.label,
                  style: TextStyle(
                    color: meta.iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Kelgan vaqti',
            value: selectedRecord!.arrivalTime ?? '-',
          ),
          _DetailRow(
            label: 'Ketgan vaqti',
            value: selectedRecord!.leavingTime ?? '-',
          ),
          _DetailRow(
            label: 'Olib ketuvchi',
            value: selectedRecord!.pickupPerson ?? '-',
          ),
          _DetailRow(
            label: 'Izoh',
            value: selectedRecord!.note ?? '-',
            isMultiline: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isMultiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            )
          : Row(
              children: [
                Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
    );
  }
}

class AttendanceStatusMeta {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color softBackground;

  const AttendanceStatusMeta({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.softBackground,
  });

  factory AttendanceStatusMeta.fromStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const AttendanceStatusMeta(
          label: 'Keldi',
          icon: Icons.check_rounded,
          iconColor: AppColors.primary,
          softBackground: Color(0xFFEAFBF8),
        );
      case AttendanceStatus.absent:
        return const AttendanceStatusMeta(
          label: 'Kelmadi',
          icon: Icons.close_rounded,
          iconColor: Color(0xFFE85D5D),
          softBackground: Color(0xFFFFEFEF),
        );
      case AttendanceStatus.sick:
        return const AttendanceStatusMeta(
          label: 'Kasal',
          icon: Icons.favorite_border_rounded,
          iconColor: Color(0xFF7E57C2),
          softBackground: Color(0xFFF3EEFF),
        );
      case AttendanceStatus.excused:
        return const AttendanceStatusMeta(
          label: 'Sababli',
          icon: Icons.change_history_rounded,
          iconColor: Color(0xFFF2A93B),
          softBackground: Color(0xFFFFF7E9),
        );
      case AttendanceStatus.leftEarly:
        return const AttendanceStatusMeta(
          label: 'Erta ketdi',
          icon: Icons.star_border_rounded,
          iconColor: Color(0xFF5C8DF6),
          softBackground: Color(0xFFEDF3FF),
        );
    }
  }
}
