import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/splash_config_model.dart';
import '../services/app_warmup_service.dart';
import '../services/bolajonim_api.dart';
import '../services/splash_service.dart';
import '../theme/app_colors.dart';

/// Shows only a director-uploaded splash image. Default branding lives on
/// [StartScreen] — no app icon here to avoid showing it twice in a row.
class SplashLoadingScreen extends StatefulWidget {
  final SplashConfigModel? config;

  const SplashLoadingScreen({super.key, this.config});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  bool _imageReady = false;
  String? _resolvedImageUrl;

  @override
  void initState() {
    super.initState();
    _prepareSplashImage();
  }

  SplashConfigModel? get _config => widget.config ?? SplashService.current;

  Future<void> _prepareSplashImage() async {
    final imageUrl = BolajonimApi.resolveMediaUrl(_config?.imageUrl);
    if (imageUrl == null || imageUrl.isEmpty) {
      if (mounted) {
        setState(() => _imageReady = true);
        SplashService.markSplashImageReady();
      }
      return;
    }

    _resolvedImageUrl = imageUrl;

    try {
      if (mounted) {
        await precacheImage(NetworkImage(imageUrl), context);
      }
    } catch (_) {
      // Fall back to plain background if the image cannot be cached.
    }

    if (mounted) {
      setState(() => _imageReady = true);
      SplashService.markSplashImageReady();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolvedImageUrl;
    final hasCustomImage = imageUrl != null && imageUrl.isNotEmpty;

    // On web, the HTML splash layer handles full-bleed imagery; keep Flutter
    // underneath neutral so no colored bar leaks into the status area later.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (hasCustomImage && _imageReady)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AppColors.background),
            ),
          Offstage(
            child: Row(children: AppWarmupService.offstageCountryFlags()),
          ),
        ],
      ),
    );
  }
}
