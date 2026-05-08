import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '/../features/home/presentation/screens/schedule_screen.dart';
import '/../features/home/presentation/screens/report_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  late final List<Widget> _pages = [
    HomeScreen(onOpenProfile: () => _onItemTapped(3)),
    const ScheduleScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedIndex,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RepaintBoundary(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 88,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = constraints.maxWidth / 4;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOutCubicEmphasized,
                    left: itemWidth * _selectedIndex,
                    top: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: itemWidth - 12,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_rounded,
                        activeIcon: Icons.home_rounded,
                        label: 'Asosiy',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today_rounded,
                        label: 'Jadval',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.article_outlined,
                        activeIcon: Icons.article_rounded,
                        label: 'Hisobot',
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset: isSelected ? Offset.zero : const Offset(0, 0.08),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  scale: isSelected ? 1.08 : 1.0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey('${label}_$isSelected'),
                      size: 24,
                      color: isSelected ? AppColors.primary : Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.black54,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
