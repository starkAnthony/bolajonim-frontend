import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_service.dart';

enum UserRole { parent, teacher, director, unknown }

class SessionService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final Map<String, String> _webStorage = {};
  static const _pendingInviteKey = 'pending_kg_invite_code';
  static const _pendingRelationKey = 'pending_parent_relation';

  static Future<void> saveRole(String? rofcCd) async {
    final role = _mapRole(rofcCd);
    await AuthService.saveUserRole(role.name);
  }

  static Future<UserRole> getRole() async {
    final value = await AuthService.getUserRole();
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.unknown,
    );
  }

  static Future<void> savePendingInviteCode(String inviteCode) async {
    final code = inviteCode.trim();
    if (code.isEmpty) return;
    if (kIsWeb) {
      _webStorage[_pendingInviteKey] = code;
    } else {
      await _storage.write(key: _pendingInviteKey, value: code);
    }
  }

  static Future<String?> consumePendingInviteCode() async {
    final code = kIsWeb
        ? _webStorage.remove(_pendingInviteKey)
        : await _storage.read(key: _pendingInviteKey);
    if (!kIsWeb && code != null) {
      await _storage.delete(key: _pendingInviteKey);
    }
    return code;
  }

  static Future<void> savePendingRelation(String relation) async {
    final value = relation.trim();
    if (value.isEmpty) return;
    if (kIsWeb) {
      _webStorage[_pendingRelationKey] = value;
    } else {
      await _storage.write(key: _pendingRelationKey, value: value);
    }
  }

  static Future<String?> consumePendingRelation() async {
    final relation = kIsWeb
        ? _webStorage.remove(_pendingRelationKey)
        : await _storage.read(key: _pendingRelationKey);
    if (!kIsWeb && relation != null) {
      await _storage.delete(key: _pendingRelationKey);
    }
    return relation;
  }

  static UserRole _mapRole(String? rofcCd) {
    final normalized = (rofcCd ?? '').toUpperCase();
    if (normalized.contains('TEACHER')) return UserRole.teacher;
    if (normalized.contains('DIRECTOR') || normalized.contains('ADMIN')) {
      return UserRole.director;
    }
    if (normalized.contains('PARENT')) return UserRole.parent;
    return UserRole.parent;
  }
}
