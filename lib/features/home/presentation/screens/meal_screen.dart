import 'package:flutter/material.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealDays = _dummyMealDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Taomnoma',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: mealDays.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _MealHeaderCard(
                childName: 'SALIH (Sali)',
                groupName: 'Kichik guruh',
              );
            }

            final day = mealDays[index - 1];
            return _MealDaySection(day: day);
          },
        ),
      ),
    );
  }
}

class MealDayData {
  final DateTime date;
  final List<MealPhotoItem> meals;

  const MealDayData({required this.date, required this.meals});
}

class MealPhotoItem {
  final String mealType;
  final String imagePath;
  final String? menuText;
  final String? note;

  const MealPhotoItem({
    required this.mealType,
    required this.imagePath,
    this.menuText,
    this.note,
  });
}

class _MealHeaderCard extends StatelessWidget {
  final String childName;
  final String groupName;

  const _MealHeaderCard({required this.childName, required this.groupName});

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
              Icons.restaurant_menu_rounded,
              size: 28,
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

class _MealDaySection extends StatelessWidget {
  final MealDayData day;

  const _MealDaySection({required this.day});

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
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_dateLabel(day.date), style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: day.meals
                .map(
                  (meal) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: meal == day.meals.last ? 0 : 10,
                      ),
                      child: _MealPhotoCard(item: meal, date: day.date),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MealPhotoCard extends StatelessWidget {
  final MealPhotoItem item;
  final DateTime date;

  const _MealPhotoCard({required this.item, required this.date});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealDetailScreen(date: date, item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xFFF4F7FA),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 36,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                item.mealType,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final DateTime date;
  final MealPhotoItem item;

  const MealDetailScreen({super.key, required this.date, required this.item});

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          item.mealType,
          style: const TextStyle(
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
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFF4F7FA),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 44,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.mealType,
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(_dateLabel(date), style: AppTextStyles.bodySmall),
                        if ((item.menuText ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Taom tarkibi',
                            style: AppTextStyles.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(item.menuText!, style: AppTextStyles.bodyMedium),
                        ],
                        if ((item.note ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Izoh', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 8),
                          Text(item.note!, style: AppTextStyles.bodyMedium),
                        ],
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

final List<MealDayData> _dummyMealDays = [
  MealDayData(
    date: DateTime(2026, 4, 20),
    meals: const [
      MealPhotoItem(
        mealType: 'Nonushta',
        imagePath: 'assets/images/meals/2026_04_20_morning.jpg',
        menuText: 'Banana bo‘laklari.',
        note: 'Yaxshi yedi.',
      ),
      MealPhotoItem(
        mealType: 'Tushlik',
        imagePath: 'assets/images/meals/2026_04_20_lunch.jpg',
        menuText: 'Guruch, ko‘katli sho‘rva, sabzavot salati.',
        note: 'Asosiy ovqatni yaxshi yedi.',
      ),
      MealPhotoItem(
        mealType: 'Kechki Snacks',
        imagePath: 'assets/images/meals/2026_04_20_afternoon.jpg',
        menuText: 'Kruassan va sut.',
        note: 'Tamaddini tugatdi.',
      ),
    ],
  ),
  MealDayData(
    date: DateTime(2026, 4, 19),
    meals: const [
      MealPhotoItem(
        mealType: 'Ertalabki tamaddi',
        imagePath: 'assets/images/meals/2026_04_19_morning.jpg',
        menuText: 'Sutli bo‘tqa.',
        note: 'Sekinroq yedi.',
      ),
      MealPhotoItem(
        mealType: 'Tushlik',
        imagePath: 'assets/images/meals/2026_04_19_lunch.jpg',
        menuText: 'Guruch, makkajo‘xori aralashmasi, salat, ko‘katli sho‘rva.',
        note: 'O‘rtacha ishtaha bilan yedi.',
      ),
      MealPhotoItem(
        mealType: 'Kechki tamaddi',
        imagePath: 'assets/images/meals/2026_04_19_afternoon.jpg',
        menuText: 'Keks va ichimlik.',
        note: 'Kamroq yedi.',
      ),
    ],
  ),
  MealDayData(
    date: DateTime(2026, 4, 18),
    meals: const [
      MealPhotoItem(
        mealType: 'Ertalabki tamaddi',
        imagePath: 'assets/images/meals/2026_04_18_morning.jpg',
        menuText: 'Olma bo‘laklari.',
      ),
      MealPhotoItem(
        mealType: 'Tushlik',
        imagePath: 'assets/images/meals/2026_04_18_lunch.jpg',
        menuText: 'Guruch, sabzavotli sho‘rva, yon taomlar.',
      ),
      MealPhotoItem(
        mealType: 'Kechki tamaddi',
        imagePath: 'assets/images/meals/2026_04_18_afternoon.jpg',
        menuText: 'Pishiriq va sut.',
      ),
    ],
  ),
];
