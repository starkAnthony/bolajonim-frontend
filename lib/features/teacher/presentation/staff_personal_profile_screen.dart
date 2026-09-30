import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/staff_personal_profile_model.dart';
import '../../../core/services/bolajonim_api.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/api_error_utils.dart';
import '../../../core/widgets/profile_photo_crop_screen.dart';
import '../../../core/widgets/profile_photo_viewer.dart';

class StaffPersonalProfileScreen extends StatefulWidget {
  final String? userId;
  final bool readOnly;

  const StaffPersonalProfileScreen({
    super.key,
    this.userId,
    this.readOnly = false,
  });

  @override
  State<StaffPersonalProfileScreen> createState() =>
      _StaffPersonalProfileScreenState();
}

class _StaffPersonalProfileScreenState extends State<StaffPersonalProfileScreen> {
  final _nameController = TextEditingController();
  final _nickController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _picker = ImagePicker();

  late Future<StaffPersonalProfileModel> _profileFuture;
  Uint8List? _pickedPhotoBytes;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<StaffPersonalProfileModel> _loadProfile() {
    if (widget.readOnly && widget.userId != null) {
      return TeacherApi.getTeacherPersonalProfileForDirector(widget.userId!);
    }
    return TeacherApi.getStaffPersonalProfile();
  }

  void _reload() {
    setState(() {
      _pickedPhotoBytes = null;
      _profileFuture = _loadProfile();
    });
  }

  void _fillFields(StaffPersonalProfileModel profile) {
    _nameController.text = profile.userName;
    _nickController.text = profile.nickName ?? '';
    _ageController.text = profile.ageYr?.toString() ?? '';
    _addressController.text = profile.homeAddress ?? '';
    _noteController.text = profile.profileNote ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nickController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (widget.readOnly || _isUploadingPhoto) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2000,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    final cropped = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProfilePhotoCropScreen(imageBytes: bytes),
      ),
    );
    if (cropped == null || !mounted) return;
    setState(() {
      _pickedPhotoBytes = cropped;
      _isUploadingPhoto = true;
    });
    try {
      await TeacherApi.uploadStaffPhoto(
        fileBytes: cropped,
        fileName: 'staff-photo.png',
      );
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiErrorUtils.localize('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _openPhoto(StaffPersonalProfileModel profile) async {
    final photoUrl = BolajonimApi.resolveMediaUrl(profile.photoUrl);
    final hasPhoto = _pickedPhotoBytes != null ||
        (photoUrl != null && photoUrl.isNotEmpty);
    if (!hasPhoto) {
      await _pickPhoto();
      return;
    }
    final action = await Navigator.push<ProfilePhotoAction>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePhotoViewer(
          title: profile.userName,
          imageBytes: _pickedPhotoBytes,
          imageUrl: photoUrl,
          canEdit: !widget.readOnly,
        ),
      ),
    );
    if (!mounted || action == null || widget.readOnly) return;
    if (action == ProfilePhotoAction.change) {
      await _pickPhoto();
    } else if (action == ProfilePhotoAction.delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rasmni o‘chirish'),
          content: const Text('Profil rasmi o‘chirilsinmi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D5D),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('O‘chirish'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      try {
        await TeacherApi.deleteStaffPhoto();
        if (!mounted) return;
        setState(() => _pickedPhotoBytes = null);
        _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorUtils.localize('$e'))),
        );
      }
    }
  }

  Future<void> _save() async {
    if (widget.readOnly) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ism va familiyani kiriting.')),
      );
      return;
    }
    final ageText = _ageController.text.trim();
    int? age;
    if (ageText.isNotEmpty) {
      age = int.tryParse(ageText);
      if (age == null || age < 16 || age > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yosh noto‘g‘ri.')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      await TeacherApi.updateStaffPersonalProfile(
        userName: name,
        nickName: _nickController.text.trim(),
        ageYr: age,
        homeAddress: _addressController.text.trim(),
        profileNote: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ma’lumotlar saqlandi.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saqlashda xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.readOnly ? 'Shaxsiy ma’lumotlar' : 'Profil sozlamalari';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (!widget.readOnly)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Saqlash',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
        ],
      ),
      body: FutureBuilder<StaffPersonalProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Yuklab bo‘lmadi: ${snapshot.error}'));
          }

          final profile = snapshot.data!;
          if (_nameController.text.isEmpty) {
            _fillFields(profile);
          }

          final photoUrl = BolajonimApi.resolveMediaUrl(profile.photoUrl);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _openPhoto(profile),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: const Color(0xFFEFF8F6),
                        backgroundImage: _pickedPhotoBytes != null
                            ? MemoryImage(_pickedPhotoBytes!)
                            : photoUrl != null
                                ? NetworkImage(photoUrl)
                                : null,
                        child: _pickedPhotoBytes == null && photoUrl == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 56,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      if (!widget.readOnly)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton.filled(
                            onPressed: _isUploadingPhoto ? null : _pickPhoto,
                            icon: _isUploadingPhoto
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt_rounded, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(profile.roleLabel, style: AppTextStyles.bodySmall),
              ),
              const SizedBox(height: 20),
              _field(
                label: 'Ism va familiya',
                controller: _nameController,
                readOnly: widget.readOnly,
              ),
              _field(
                label: 'Laqab',
                controller: _nickController,
                readOnly: widget.readOnly,
              ),
              _field(
                label: 'Yosh',
                controller: _ageController,
                readOnly: widget.readOnly,
                keyboardType: TextInputType.number,
              ),
              _field(
                label: 'Uy manzili',
                controller: _addressController,
                readOnly: widget.readOnly,
                maxLines: 2,
              ),
              _field(
                label: 'Qo‘shimcha ma’lumot',
                controller: _noteController,
                readOnly: widget.readOnly,
                maxLines: 3,
              ),
              if (widget.readOnly) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Bu ma’lumotlar faqat direktor va o‘qituvchi o‘zi ko‘ra oladi.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF744210)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required bool readOnly,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
