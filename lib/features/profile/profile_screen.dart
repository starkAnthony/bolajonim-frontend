import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/presentation/start_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _childProfileImage;

  void _showPlaceholder(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickChildImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (pickedFile == null) return;

      setState(() {
        _childProfileImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm yuklashda xatolik yuz berdi: $e')),
      );
    }
  }

  void _deleteChildImage() {
    setState(() {
      _childProfileImage = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil rasmi o‘chirildi')));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Chiqish',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Akkauntingizdan chiqmoqchimisiz?',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Bekor qilish',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Chiqish',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartScreen()),
      (route) => false,
    );
  }

  void _showAddPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Profil rasmi qo‘shish',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rasmni qayerdan tanlaysiz?',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _PickerOptionCard(
                        icon: Icons.photo_library_rounded,
                        title: 'Galereya',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickChildImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerOptionCard(
                        icon: Icons.photo_camera_rounded,
                        title: 'Kamera',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickChildImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text(
                      'Bekor qilish',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDeleteSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Profil rasmi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quyidagilardan birini tanlang',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),
                _ActionSheetTile(
                  icon: Icons.edit_outlined,
                  title: 'Profil rasmini o‘zgartirish',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAddPhotoSheet();
                  },
                ),
                const SizedBox(height: 10),
                _ActionSheetTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Profil rasmini o‘chirish',
                  isDanger: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _deleteChildImage();
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text(
                      'Bekor qilish',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onChildImageTap() {
    if (_childProfileImage == null) {
      _showAddPhotoSheet();
    } else {
      _showEditDeleteSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profil', style: AppTextStyles.headlineMedium),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: () => _showPlaceholder(
                      context,
                      'Bildirishnomalar sahifasi keyin ulanadi.',
                    ),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _MainChildCard(
              childProfileImage: _childProfileImage,
              onImageTap: _onChildImageTap,
              onEditTap: () => _showPlaceholder(
                context,
                'Farzand profilini tahrirlash sahifasi keyin ulanadi.',
              ),
            ),

            const SizedBox(height: 12),

            const _ParentAccountCard(),

            const SizedBox(height: 12),

            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ChildSwitcherCard(
                    name: 'Salih',
                    isSelected: true,
                    onTap: () => _showPlaceholder(context, 'Salih tanlandi.'),
                  ),
                  const SizedBox(width: 12),
                  _AddChildCard(
                    onTap: () => _showPlaceholder(
                      context,
                      'Farzand qo‘shish sahifasi keyin ulanadi.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 14,
                children: [
                  _QuickActionItem(
                    icon: Icons.settings_outlined,
                    label: 'Sozlamalar',
                    onTap: () => _showPlaceholder(
                      context,
                      'Ilova sozlamalari sahifasi keyin ulanadi.',
                    ),
                  ),
                  _QuickActionItem(
                    icon: Icons.language_rounded,
                    label: 'Til',
                    onTap: () => _showPlaceholder(
                      context,
                      'Til tanlash sahifasi keyin ulanadi.',
                    ),
                  ),
                  _QuickActionItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Yordam',
                    onTap: () => _showPlaceholder(
                      context,
                      'Yordam markazi sahifasi keyin ulanadi.',
                    ),
                  ),
                  _QuickActionItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Aloqa',
                    onTap: () => _showPlaceholder(
                      context,
                      'Biz bilan bog‘lanish sahifasi keyin ulanadi.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _AccountActionTile(
              icon: Icons.logout_rounded,
              title: 'Chiqish',
              isDanger: false,
              onTap: _logout,
            ),
            const SizedBox(height: 10),
            _AccountActionTile(
              icon: Icons.delete_outline_rounded,
              title: 'Hisobni o‘chirish',
              isDanger: true,
              onTap: () => _showPlaceholder(
                context,
                'Hisobni o‘chirish logikasi keyin ulanadi.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainChildCard extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onImageTap;
  final File? childProfileImage;

  const _MainChildCard({
    required this.onEditTap,
    required this.onImageTap,
    required this.childProfileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8F6),
                        borderRadius: BorderRadius.circular(24),
                        image: childProfileImage != null
                            ? DecorationImage(
                                image: FileImage(childProfileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: childProfileImage == null
                          ? const Icon(
                              Icons.child_care_rounded,
                              size: 38,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Icon(
                          childProfileImage == null
                              ? Icons.add_a_photo_rounded
                              : Icons.edit_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salih',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Tanlangan farzand', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF6E8),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _InfoMiniCard(
                  label: 'Tug‘ilgan sana',
                  value: '15.11.2024',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoMiniCard(label: 'Guruh', value: 'Kichik guruh'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _WideInfoCard(label: 'Bog‘cha', value: 'Rainbow bog‘chasi'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEditTap,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Farzand ma’lumotlarini tahrirlash',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMiniCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoMiniCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WideInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _WideInfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildSwitcherCard extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildSwitcherCard({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF8F6) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE6EAF0),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isSelected
                  ? Colors.white
                  : const Color(0xFFF4F6F9),
              child: const Icon(
                Icons.child_friendly_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChildCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddChildCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE6EAF0), width: 1.2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFEFF8F6),
              child: Icon(Icons.add_rounded, color: AppColors.primary),
            ),
            SizedBox(height: 8),
            Text(
              'Qo‘shish',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemWidth = (MediaQuery.of(context).size.width - 40 - 28 - 24) / 4;

    return SizedBox(
      width: itemWidth.clamp(64.0, 90.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentAccountCard extends StatelessWidget {
  const _ParentAccountCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFF4F6F9),
            child: Icon(Icons.person_rounded, color: AppColors.textPrimary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stark', style: AppTextStyles.bodyMedium),
                SizedBox(height: 4),
                Text('Ota', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback onTap;

  const _AccountActionTile({
    required this.icon,
    required this.title,
    required this.isDanger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
      ),
    );
  }
}

class _PickerOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PickerOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionSheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
