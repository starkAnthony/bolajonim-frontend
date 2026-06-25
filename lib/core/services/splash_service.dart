import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/splash_config_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/bolajonim_api.dart';
import '../services/session_service.dart';
import '../utils/splash_cache.dart';

class SplashService {
  static const Duration minDisplayDuration = Duration(milliseconds: 2300);

  static const _imageUrlKey = 'splash_image_url';
  static const _captionKey = 'splash_caption';
  static const _kgNoKey = 'splash_kg_no';

  static SplashConfigModel? _current;
  static Completer<void>? _imageReadyCompleter;

  static SplashConfigModel? get current => _current;

  static void beginSplashImageWait() {
    _imageReadyCompleter = Completer<void>();
  }

  static void markSplashImageReady() {
    final completer = _imageReadyCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _imageReadyCompleter = null;
  }

  static Future<void> waitForSplashImageReady() {
    final completer = _imageReadyCompleter;
    if (completer == null) return Future.value();
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
  }



  static Future<SplashConfigModel?> loadCached() async {

    final prefs = await SharedPreferences.getInstance();

    final imageUrl = prefs.getString(_imageUrlKey);

    final caption = prefs.getString(_captionKey);

    final kgNo = prefs.getString(_kgNoKey);

    if ((imageUrl ?? '').isEmpty) return null;

    return SplashConfigModel(

      imageUrl: imageUrl,

      caption: caption,

      kgNo: kgNo,

    );

  }



  static Future<String?> loadCachedKgNo() async {

    final prefs = await SharedPreferences.getInstance();

    final kgNo = prefs.getString(_kgNoKey);

    if (kgNo == null || kgNo.trim().isEmpty) return null;

    return kgNo.trim();

  }



  static Future<void> saveCache(SplashConfigModel? config) async {

    final prefs = await SharedPreferences.getInstance();

    final imageUrl = config?.imageUrl;

    final caption = config?.caption;

    final kgNo = config?.kgNo;



    if (imageUrl != null && imageUrl.isNotEmpty) {

      await prefs.setString(_imageUrlKey, imageUrl);

    } else {

      await prefs.remove(_imageUrlKey);

    }



    if (caption != null && caption.isNotEmpty) {

      await prefs.setString(_captionKey, caption);

    } else {

      await prefs.remove(_captionKey);

    }



    if (kgNo != null && kgNo.isNotEmpty) {

      await prefs.setString(_kgNoKey, kgNo);

    } else if (config == null || !config.hasImage) {

      await prefs.remove(_kgNoKey);

    }



    final resolved = BolajonimApi.resolveMediaUrl(imageUrl);

    writeSplashCache(resolved, caption);

  }



  static Future<SplashConfigModel?> bootstrap({

    String? childNo,

  }) async {

    _current = await loadCached();



    try {

      final isLoggedIn = await AuthService.isLoggedIn();

      final fresh = await _fetchRemote(

        isLoggedIn: isLoggedIn,

        childNo: childNo,

      );

      if (fresh != null && fresh.hasImage) {

        _current = fresh;

        await saveCache(fresh);

      } else if (fresh != null && !fresh.hasImage) {

        _current = null;

        await saveCache(null);

      }

    } catch (_) {

      // Keep cached/default splash when offline.

    }



    return _current;

  }



  static Future<SplashConfigModel?> refresh({

    String? childNo,

  }) async {

    final isLoggedIn = await AuthService.isLoggedIn();

    final fresh = await _fetchRemote(

      isLoggedIn: isLoggedIn,

      childNo: childNo,

    );

    if (fresh != null && fresh.hasImage) {

      _current = fresh;

      await saveCache(fresh);

    } else if (fresh != null && !fresh.hasImage) {

      _current = null;

      await saveCache(null);

    }

    return _current;

  }



  static Future<SplashConfigModel?> _fetchRemote({

    required bool isLoggedIn,

    String? childNo,

  }) async {

    if (!isLoggedIn) {

      final kgNo = await loadCachedKgNo();

      return _fromBody(

        await ApiClient.get(

          ApiConfig.publicSplashPath,

          queryParameters: kgNo == null ? null : {'kgNo': kgNo},

          authenticated: false,

        ),

      );

    }



    final role = await SessionService.getRole();

    if (role == UserRole.parent) {

      return _fromBody(

        await ApiClient.get(

          ApiConfig.parentSplashPath,

          queryParameters: childNo == null ? null : {'childNo': childNo},

        ),

      );

    }



    if (role == UserRole.teacher || role == UserRole.director) {

      return _fromBody(await ApiClient.get(ApiConfig.staffSplashPath));

    }



    return _fromBody(

      await ApiClient.get(

        ApiConfig.publicSplashPath,

        authenticated: false,

      ),

    );

  }



  static SplashConfigModel? _fromBody(Map<String, dynamic> body) {

    final raw = body['result'];

    if (raw == null) return null;

    if (raw is! Map) return null;



    final config = SplashConfigModel.fromJson(Map<String, dynamic>.from(raw));

    if (!config.hasImage) return null;

    return config;

  }

}


