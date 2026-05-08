import 'package:flutter/material.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedMonthLabel = 'Aprel 2026';

  final List<ReportItem> _reports = _dummyReports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hisobot',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.inbox_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5ED3C6),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportWriteScreen()),
          );
        },
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _MonthFilterCard(
              selectedMonthLabel: _selectedMonthLabel,
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (_) => const _MonthPickerSheet(),
                );

                if (selected != null) {
                  setState(() {
                    _selectedMonthLabel = selected;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            const _ChildMessageBanner(),
            const SizedBox(height: 12),
            ..._reports.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReportListCard(
                  item: report,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(item: report),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ReportDirection { centerToHome, homeToCenter }

enum WeatherType { sunny, cloudy, rainy }

class ReportItem {
  final DateTime date;
  final ReportDirection direction;
  final String previewText;
  final int commentCount;
  final WeatherType weather;
  final String? imagePath;
  final bool hasAttachment;

  const ReportItem({
    required this.date,
    required this.direction,
    required this.previewText,
    required this.commentCount,
    required this.weather,
    this.imagePath,
    this.hasAttachment = false,
  });
}

class _MonthFilterCard extends StatelessWidget {
  final String selectedMonthLabel;
  final VoidCallback onTap;

  const _MonthFilterCard({
    required this.selectedMonthLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedMonthLabel,
                style: AppTextStyles.headlineMedium,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  const _MonthPickerSheet();

  @override
  Widget build(BuildContext context) {
    const months = ['Aprel 2026', 'Mart 2026', 'Fevral 2026', 'Yanvar 2026'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DDE3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Oyni tanlang', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            ...months.map(
              (month) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(month, style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context, month),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildMessageBanner extends StatelessWidget {
  const _ChildMessageBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.child_care, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Farzandingiz haqidagi quvonchli xabarlarni tarbiyachi bilan ulashing.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportListCard extends StatelessWidget {
  final ReportItem item;
  final VoidCallback onTap;

  const _ReportListCard({required this.item, required this.onTap});

  String _weekdayLabel(DateTime date) {
    const weekdays = ['', 'Du', 'Se', 'Chor', 'Pay', 'Ju', 'Sha', 'Yak'];
    return weekdays[date.weekday];
  }

  String _directionLabel(ReportDirection direction) {
    switch (direction) {
      case ReportDirection.centerToHome:
        return 'Bog‘chadan uyga';
      case ReportDirection.homeToCenter:
        return 'Uydan bog‘chaga';
    }
  }

  Color _directionColor(ReportDirection direction) {
    switch (direction) {
      case ReportDirection.centerToHome:
        return AppColors.textPrimary;
      case ReportDirection.homeToCenter:
        return const Color(0xFF4A90E2);
    }
  }

  IconData _weatherIcon(WeatherType weather) {
    switch (weather) {
      case WeatherType.sunny:
        return Icons.wb_sunny_outlined;
      case WeatherType.cloudy:
        return Icons.cloud_outlined;
      case WeatherType.rainy:
        return Icons.umbrella_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.date.day}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekdayLabel(item.date),
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Icon(
                    _weatherIcon(item.weather),
                    color: AppColors.textSecondary,
                    size: 26,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.commentCount}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _directionLabel(item.direction),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _directionColor(item.direction),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.previewText,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if ((item.imagePath ?? '').trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: Image.asset(
                    item.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFFF4F7FA),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final ReportItem item;

  const ReportDetailScreen({super.key, required this.item});

  String _dateLabel(DateTime date) {
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
    return '${date.day}-${months[date.month]}, ${date.year}';
  }

  String _directionLabel(ReportDirection direction) {
    switch (direction) {
      case ReportDirection.centerToHome:
        return 'Bog‘chadan uyga';
      case ReportDirection.homeToCenter:
        return 'Uydan bog‘chaga';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hisobot tafsiloti',
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((item.imagePath ?? '').trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: Image.asset(
                          item.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFF4F7FA),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _directionLabel(item.direction),
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dateLabel(item.date),
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        Text(item.previewText, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.commentCount} ta izoh',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportWriteScreen extends StatelessWidget {
  const ReportWriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hisobot yozish',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<ReportDirection>(
                      value: ReportDirection.homeToCenter,
                      decoration: InputDecoration(
                        labelText: 'Yo‘nalish',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ReportDirection.homeToCenter,
                          child: Text('Uydan bog‘chaga'),
                        ),
                        DropdownMenuItem(
                          value: ReportDirection.centerToHome,
                          child: Text('Bog‘chadan uyga'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText: 'Farzandingiz haqida qisqacha yozing...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Saqlash'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<ReportItem> _dummyReports = [
  ReportItem(
    date: DateTime(2026, 4, 20),
    direction: ReportDirection.centerToHome,
    previewText: 'Assalomu alaykum, bugun Sali yaxshi kayfiyatda o‘ynadi 😊',
    commentCount: 1,
    weather: WeatherType.sunny,
    imagePath: '',
  ),
  ReportItem(
    date: DateTime(2026, 4, 20),
    direction: ReportDirection.centerToHome,
    previewText:
        'Bugun ovqatdan keyin biroz charchadi, lekin keyin yaxshi o‘ynadi.',
    commentCount: 2,
    weather: WeatherType.sunny,
    imagePath: '',
  ),
  ReportItem(
    date: DateTime(2026, 4, 17),
    direction: ReportDirection.homeToCenter,
    previewText: 'Assalomu alaykum ustoz, bugun Sali biroz uyqusirab turibdi.',
    commentCount: 1,
    weather: WeatherType.cloudy,
    imagePath: '',
  ),
  ReportItem(
    date: DateTime(2026, 4, 15),
    direction: ReportDirection.centerToHome,
    previewText: 'Bugun rasm chizish mashg‘ulotida faol qatnashdi 😊',
    commentCount: 4,
    weather: WeatherType.sunny,
    imagePath: '',
  ),
  ReportItem(
    date: DateTime(2026, 4, 14),
    direction: ReportDirection.centerToHome,
    previewText:
        'Ochiq havoda yaxshi o‘ynadi va do‘stlari bilan muloqot qildi.',
    commentCount: 2,
    weather: WeatherType.cloudy,
    imagePath: '',
  ),
];
