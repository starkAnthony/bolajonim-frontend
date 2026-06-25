import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NetworkImageFrame extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final VoidCallback? onTap;

  const NetworkImageFrame({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.contain,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    Widget child = Container(
      width: width,
      height: height,
      color: const Color(0xFFF4F7FA),
      alignment: Alignment.center,
      child: hasUrl
          ? Image.network(
              imageUrl!,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textSecondary,
              ),
            )
          : const Icon(
              Icons.image_outlined,
              color: AppColors.textSecondary,
            ),
    );

    if (borderRadius != BorderRadius.zero) {
      child = ClipRRect(borderRadius: borderRadius, child: child);
    }

    if (onTap != null) {
      child = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: child,
        ),
      );
    }

    return child;
  }
}

class MemoryImageFrame extends StatelessWidget {
  final List<int> bytes;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const MemoryImageFrame({
    super.key,
    required this.bytes,
    required this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      width: width,
      height: height,
      color: const Color(0xFFF4F7FA),
      alignment: Alignment.center,
      child: Image.memory(
        bytes is Uint8List ? bytes as Uint8List : Uint8List.fromList(bytes),
        fit: BoxFit.contain,
        width: width,
        height: height,
      ),
    );

    if (borderRadius != BorderRadius.zero) {
      child = ClipRRect(borderRadius: borderRadius, child: child);
    }

    if (onTap != null) {
      child = GestureDetector(onTap: onTap, child: child);
    }

    return child;
  }
}
