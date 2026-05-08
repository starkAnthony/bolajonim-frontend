import 'package:flutter/material.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late DateTime _selectedDate;

  final Map<DateTime, DailyGalleryData> _galleryMap = {
    _dateOnly(DateTime(2026, 4, 20)): DailyGalleryData(
      teacherNote:
          'Bugun bolalar rasm chizish, ochiq havoda o‘ynash va birgalikdagi faoliyatlardan juda xursand bo‘lishdi.',
      albums: [
        GalleryAlbum(
          title: 'Ertalabki mashg‘ulot',
          subtitle: 'Rasm chizish va ranglarni o‘rganish',
          coverImage:
              'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=1200&q=80',
          photoCount: 4,
          photos: const [
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=1200&q=80',
              caption: 'Ranglar bilan ishlash',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1511988617509-a57c8a288659?auto=format&fit=crop&w=1200&q=80',
              caption: 'Birgalikdagi ijodiy ish',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?auto=format&fit=crop&w=1200&q=80',
              caption: 'Do‘stlari bilan mashg‘ulot',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1200&q=80',
              caption: 'Tayyor ishlarni ko‘rsatish',
            ),
          ],
        ),
        GalleryAlbum(
          title: 'Ochiq havo',
          subtitle: 'Maydonchadagi faol o‘yinlar',
          coverImage:
              'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1200&q=80',
          photoCount: 5,
          photos: const [
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1200&q=80',
              caption: 'Maydonchada yugurish',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1542810634-71277d95dcbb?auto=format&fit=crop&w=1200&q=80',
              caption: 'Birgalikda o‘yin',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?auto=format&fit=crop&w=1200&q=80',
              caption: 'Kulgu va quvonchli lahzalar',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1511988617509-a57c8a288659?auto=format&fit=crop&w=1200&q=80',
              caption: 'Do‘stlari bilan vaqt',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=1200&q=80',
              caption: 'Faol harakatlar',
            ),
          ],
        ),
      ],
    ),
    _dateOnly(DateTime(2026, 4, 19)): DailyGalleryData(
      teacherNote:
          'Bugun sokinroq kun bo‘ldi. Hikoya va konstruktor bilan mashg‘ulotlar qilindi.',
      albums: [
        GalleryAlbum(
          title: 'Kitob va hikoya vaqti',
          subtitle: 'Rasmlar ko‘rish va tinglash',
          coverImage:
              'https://images.unsplash.com/photo-1588072432836-e10032774350?auto=format&fit=crop&w=1200&q=80',
          photoCount: 3,
          photos: const [
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1588072432836-e10032774350?auto=format&fit=crop&w=1200&q=80',
              caption: 'Hikoyani tinglash',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=1200&q=80',
              caption: 'Kitob bilan tanishish',
            ),
            GalleryPhoto(
              imageUrl:
                  'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?auto=format&fit=crop&w=1200&q=80',
              caption: 'Davra suhbati',
            ),
          ],
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
    final data = _galleryMap[_selectedDate];
    final isToday = _selectedDate == _dateOnly(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Galereya',
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
            const _GalleryHeaderCard(
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
              _EmptyGalleryCard(dateLabel: _dateLabel(_selectedDate))
            else ...[
              _TeacherNoteCard(note: data.teacherNote),
              const SizedBox(height: 12),
              ...data.albums.map(
                (album) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GalleryAlbumCard(album: album),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DailyGalleryData {
  final String teacherNote;
  final List<GalleryAlbum> albums;

  const DailyGalleryData({required this.teacherNote, required this.albums});
}

class GalleryAlbum {
  final String title;
  final String subtitle;
  final String coverImage;
  final int photoCount;
  final List<GalleryPhoto> photos;

  const GalleryAlbum({
    required this.title,
    required this.subtitle,
    required this.coverImage,
    required this.photoCount,
    required this.photos,
  });
}

class GalleryPhoto {
  final String imageUrl;
  final String caption;

  const GalleryPhoto({required this.imageUrl, required this.caption});
}

class _GalleryHeaderCard extends StatelessWidget {
  final String childName;
  final String groupName;

  const _GalleryHeaderCard({required this.childName, required this.groupName});

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
            backgroundColor: Color(0xFFFFF5EA),
            child: Icon(
              Icons.photo_library_rounded,
              size: 26,
              color: Color(0xFFFF9F43),
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
                  isToday ? 'Bugungi galereya' : 'Tanlangan sana',
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
                const Text('Tarbiyachi izohi', style: AppTextStyles.titleLarge),
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

class _GalleryAlbumCard extends StatelessWidget {
  final GalleryAlbum album;

  const _GalleryAlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GalleryAlbumDetailScreen(album: album),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  album.coverImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xFFF4F7FA),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 6),
                  Text(album.subtitle, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${album.photoCount} ta rasm',
                          style: const TextStyle(
                            color: Color(0xFFFF9F43),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Ochish',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
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

class _EmptyGalleryCard extends StatelessWidget {
  final String dateLabel;

  const _EmptyGalleryCard({required this.dateLabel});

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
            'Bu sana uchun galereya ma’lumoti yo‘q.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class GalleryAlbumDetailScreen extends StatelessWidget {
  final GalleryAlbum album;

  const GalleryAlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          album.title,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 6),
                  Text(album.subtitle, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  Text(
                    '${album.photoCount} ta rasm',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: album.photos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final photo = album.photos[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GalleryViewerScreen(
                          photos: album.photos,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      photo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFF4F7FA),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryViewerScreen extends StatefulWidget {
  final List<GalleryPhoto> photos;
  final int initialIndex;

  const GalleryViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends State<GalleryViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      widget.photos[index].imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 40,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            color: Colors.black,
            child: Text(
              photo.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
