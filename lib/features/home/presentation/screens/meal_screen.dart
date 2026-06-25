import 'package:flutter/material.dart';
import '/../../core/models/meal_model.dart';
import '/../../core/services/bolajonim_api.dart';
import '/../../core/services/selected_child_service.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<MealDayData> _mealDays = [];
  bool _isLoading = true;
  String _childName = 'Farzand';
  String _groupName = '-';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);

    try {
      final children = await BolajonimApi.getChildren();
      if (children.isEmpty) {
        if (!mounted) return;
        setState(() {
          _mealDays = [];
          _isLoading = false;
        });
        return;
      }

      final childNo = await SelectedChildService.resolveSelection(children);
      final child = children.firstWhere(
        (item) => item.childNo == childNo,
        orElse: () => children.first,
      );

      final month =
          '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}';
      final meals = await BolajonimApi.getMeals(
        childNo: child.childNo,
        mealMonth: month,
      );

      final grouped = <String, List<MealPhotoItem>>{};
      for (final meal in meals) {
        final date = meal.parsedDate;
        if (date == null) continue;
        final key = BolajonimDateParser.toYyyyMmDd(date);
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(
          MealPhotoItem(
            mealType: meal.mealType,
            imageUrl: meal.imageUrl,
            menuText: meal.menuText,
            note: meal.noteText,
          ),
        );
      }

      final days = grouped.entries
          .map((entry) {
            final date = BolajonimDateParser.parseYyyyMmDd(entry.key);
            if (date == null) return null;
            return MealDayData(date: date, meals: entry.value);
          })
          .whereType<MealDayData>()
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _mealDays = days;
        _childName = child.childName;
        _groupName = child.groupName ?? '-';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mealDays = [];
        _isLoading = false;
      });
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
          'Taomnoma',
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
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _mealDays.isEmpty ? 2 : _mealDays.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _MealHeaderCard(
                      childName: _childName,
                      groupName: _groupName,
                    );
                  }

                  if (_mealDays.isEmpty) {
                    return const Text(
                      'Bu oy uchun taomnoma ma’lumoti yo‘q.',
                      style: AppTextStyles.bodyMedium,
                    );
                  }

                  final day = _mealDays[index - 1];
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
  final String? imageUrl;
  final String? menuText;
  final String? note;

  const MealPhotoItem({
    required this.mealType,
    this.imageUrl,
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
                child: _MealImage(imageUrl: item.imageUrl),
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
                    child: _MealImage(imageUrl: item.imageUrl),
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

class _MealImage extends StatelessWidget {
  final String? imageUrl;

  const _MealImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF4F7FA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_menu_rounded,
        size: 36,
        color: AppColors.textSecondary,
      ),
    );
  }
}
