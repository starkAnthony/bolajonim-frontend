import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'director_home_screen.dart';

import 'director_children_screen.dart';
import 'director_groups_screen.dart';
import 'director_staff_screen.dart';

import 'teacher_home_screen.dart';

import 'teacher_class_screen.dart';

import 'teacher_reports_screen.dart';

import 'teacher_messages_screen.dart';

import 'teacher_profile_screen.dart';



class TeacherMainNavigationScreen extends StatefulWidget {

  final bool isDirector;



  const TeacherMainNavigationScreen({

    super.key,

    this.isDirector = false,

  });



  @override

  State<TeacherMainNavigationScreen> createState() =>

      _TeacherMainNavigationScreenState();

}



class _TeacherMainNavigationScreenState

    extends State<TeacherMainNavigationScreen> {

  int _currentIndex = 0;

  final _groupsScreenKey = GlobalKey<DirectorGroupsScreenState>();
  final _reportsScreenKey = GlobalKey<TeacherReportsScreenState>();



  late final List<Widget> _screens;



  @override

  void initState() {

    super.initState();

    _screens = [

      widget.isDirector

          ? DirectorHomeScreen(

              onOpenGroups: () => _switchTab(1),

              onOpenChildren: _openChildren,

              onOpenStaff: _openStaff,

            )

          : const TeacherHomeScreen(),

      widget.isDirector

          ? DirectorGroupsScreen(key: _groupsScreenKey)

          : const TeacherClassScreen(),

      TeacherReportsScreen(key: _reportsScreenKey),

      const TeacherMessagesScreen(),

      const TeacherProfileScreen(),

    ];

  }



  void _switchTab(int index) {

    if (_currentIndex == index) {

      if (widget.isDirector && index == 1) {

        _groupsScreenKey.currentState?.reload();

      }

      if (index == 2) {

        _reportsScreenKey.currentState?.reload();

      }

      return;

    }

    setState(() => _currentIndex = index);

    if (index == 2) {

      _reportsScreenKey.currentState?.reload();

    }

  }



  Future<void> _openStaff() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DirectorStaffScreen()),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openChildren() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DirectorChildrenScreen()),
    );
    if (!mounted) return;
    setState(() {});
  }



  @override

  Widget build(BuildContext context) {

    return PopScope(

      canPop: false,

      child: Scaffold(

        backgroundColor: AppColors.background,

        body: IndexedStack(

          index: _currentIndex,

          children: _screens,

        ),

        bottomNavigationBar: SafeArea(

          top: false,

          child: Container(

            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),

            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(24),

              boxShadow: const [

                BoxShadow(

                  color: Color(0x14000000),

                  blurRadius: 20,

                  offset: Offset(0, 8),

                ),

              ],

            ),

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [

                _NavItem(

                  icon: Icons.space_dashboard_rounded,

                  label: 'Bosh',

                  isSelected: _currentIndex == 0,

                  onTap: () => _switchTab(0),

                ),

                _NavItem(

                  icon: Icons.groups_2_rounded,

                  label: 'Guruh',

                  isSelected: _currentIndex == 1,

                  onTap: () => _switchTab(1),

                ),

                _NavItem(

                  icon: Icons.edit_note_rounded,

                  label: 'Hisobot',

                  isSelected: _currentIndex == 2,

                  onTap: () => _switchTab(2),

                ),

                _NavItem(

                  icon: Icons.chat_bubble_outline_rounded,

                  label: 'Xabar',

                  isSelected: _currentIndex == 3,

                  onTap: () => _switchTab(3),

                ),

                _NavItem(

                  icon: Icons.person_outline_rounded,

                  label: 'Profil',

                  isSelected: _currentIndex == 4,

                  onTap: () => _switchTab(4),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}



class _NavItem extends StatelessWidget {

  final IconData icon;

  final String label;

  final bool isSelected;

  final VoidCallback onTap;



  const _NavItem({

    required this.icon,

    required this.label,

    required this.isSelected,

    required this.onTap,

  });



  @override

  Widget build(BuildContext context) {

    final color = isSelected ? AppColors.primary : Colors.grey.shade500;



    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 220),

        curve: Curves.easeOut,

        padding: EdgeInsets.symmetric(

          horizontal: isSelected ? 14 : 10,

          vertical: 10,

        ),

        decoration: BoxDecoration(

          color: isSelected

              ? AppColors.primary.withOpacity(0.12)

              : Colors.transparent,

          borderRadius: BorderRadius.circular(18),

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(icon, color: color, size: 22),

            const SizedBox(height: 4),

            Text(

              label,

              style: TextStyle(

                fontSize: 11,

                fontWeight: FontWeight.w700,

                color: color,

              ),

            ),

          ],

        ),

      ),

    );

  }

}


