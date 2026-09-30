import 'dart:typed_data';

import 'package:flutter/material.dart';

enum ProfilePhotoAction { change, delete }

/// Full-screen view of a saved profile photo, with change and delete.
class ProfilePhotoViewer extends StatelessWidget {
  final String title;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final bool canEdit;

  const ProfilePhotoViewer({
    super.key,
    required this.title,
    this.imageBytes,
    this.imageUrl,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? provider = imageBytes != null
        ? MemoryImage(imageBytes!)
        : (imageUrl != null && imageUrl!.isNotEmpty)
            ? NetworkImage(imageUrl!)
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121417),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: provider == null
                ? const Center(
                    child: Text(
                      'Rasm yo‘q',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: Image(
                        image: provider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
          if (canEdit)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, ProfilePhotoAction.change),
                        icon: const Icon(Icons.photo_camera_rounded),
                        label: const Text('O‘zgartirish'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, ProfilePhotoAction.delete),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('O‘chirish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85D5D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
