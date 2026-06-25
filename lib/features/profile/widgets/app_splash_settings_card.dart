import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/splash_config_model.dart';
import '../../../core/services/splash_service.dart';
import '../../../core/services/teacher_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/network_image_frame.dart';

class AppSplashSettingsCard extends StatefulWidget {
  const AppSplashSettingsCard({super.key});

  @override
  State<AppSplashSettingsCard> createState() => _AppSplashSettingsCardState();
}

class _AppSplashSettingsCardState extends State<AppSplashSettingsCard> {
  late Future<SplashConfigModel?> _splashFuture;
  final _captionController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _splashFuture = TeacherApi.getDirectorSplash();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _splashFuture = TeacherApi.getDirectorSplash();
    });
  }

  Future<void> _pickAndUpload() async {
    if (_isUploading) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (bytes.length > 8 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rasm juda katta. Boshqasini tanlang.')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploaded = await TeacherApi.uploadDirectorSplash(
        fileBytes: bytes,
        fileName: image.name.isNotEmpty ? image.name : 'splash.jpg',
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
      );
      await SplashService.saveCache(uploaded);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Splash rasm saqlandi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yuklashda xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _removeSplash(SplashConfigModel splash) async {
    final splashNo = splash.splashNo;
    if (splashNo == null) return;

    setState(() => _isUploading = true);
    try {
      await TeacherApi.deleteDirectorSplash(splashNo);
      await SplashService.saveCache(null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Splash rasm o‘chirildi.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O‘chirishda xatolik: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SplashConfigModel?>(
      future: _splashFuture,
      builder: (context, snapshot) {
        final splash = snapshot.data;
        final imageUrl = TeacherApi.resolvePhotoUrl(splash?.imageUrl);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ilova ochilganda ko‘rinadigan mavsumiy rasm. Navruz, Yangi yil va boshqa bayramlar uchun almashtiring.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 14),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: NetworkImageFrame(
                  imageUrl: imageUrl,
                  height: 180,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Matn (ixtiyoriy)',
                hintText: 'Masalan: Navro‘z muborak!',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.photo_library_outlined),
                    label: Text(
                      splash?.hasImage == true
                          ? 'Rasmni almashtirish'
                          : 'Rasm yuklash',
                    ),
                  ),
                ),
                if (splash?.hasImage == true) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'O‘chirish',
                    onPressed:
                        _isUploading ? null : () => _removeSplash(splash!),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}
