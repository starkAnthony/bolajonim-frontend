import 'package:flutter/material.dart';

import '../models/country_phone_code.dart';
import '../services/bolajonim_api.dart';
import '../models/splash_config_model.dart';
import '../theme/app_text_styles.dart';

class AppWarmupService {
  static bool _emojiWarmed = false;

  static Future<void> warmup({SplashConfigModel? splash}) async {
    if (!_emojiWarmed) {
      for (final country in CountryPhoneCode.supported) {
        country.flagEmoji.characters.length;
      }
      _emojiWarmed = true;
    }

  }

  static Future<void> warmupWithContext(
    BuildContext context, {
    SplashConfigModel? splash,
  }) async {
    await warmup(splash: splash);

    if (!context.mounted) return;

    final imageUrl = BolajonimApi.resolveMediaUrl(splash?.imageUrl);
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      await precacheImage(NetworkImage(imageUrl), context);
    } catch (_) {
      // Splash still works without precache.
    }
  }

  static List<Widget> offstageCountryFlags() {
    return CountryPhoneCode.supported
        .map(
          (country) => Text(
            country.flagEmoji,
            style: AppTextStyles.countryFlag,
          ),
        )
        .toList();
  }
}
