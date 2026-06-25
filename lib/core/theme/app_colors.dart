import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5ED3C6);
  static const secondary = Color(0xFF7BC6FF);
  static const accent = Color(0xFFFFD66B);
  static const background = Color(0xFFF8FBFF);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF7A7A7A);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);
  /// Empty text field background — distinct from typed text (not white/dark).
  static const inputFill = Color(0xFFF3F5F8);

  static Color inputSurface({
    bool hasError = false,
    bool focused = false,
    bool hasText = false,
  }) {
    if (hasError) return const Color(0xFFFFF5F5);
    if (focused || hasText) return Colors.white;
    return inputFill;
  }
}
