import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/save_network_image.dart';

class ReportPhotoViewerItem {
  final String url;
  final String fileName;
  final String? caption;

  const ReportPhotoViewerItem({
    required this.url,
    required this.fileName,
    this.caption,
  });
}

class ReportPhotoViewerScreen extends StatefulWidget {
  final List<ReportPhotoViewerItem> photos;
  final int initialIndex;

  const ReportPhotoViewerScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  State<ReportPhotoViewerScreen> createState() =>
      _ReportPhotoViewerScreenState();
}

class _ReportPhotoViewerScreenState extends State<ReportPhotoViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentPhoto() async {
    if (_isSaving) return;

    final photo = widget.photos[_currentIndex];
    setState(() => _isSaving = true);

    try {
      await SaveNetworkImage.save(
        photo.url,
        fileName: photo.fileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rasm yuklab olindi.')),
      );
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
    final photo = widget.photos[_currentIndex];
    final caption = photo.caption?.trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Yuklab olish',
            onPressed: _isSaving ? null : _saveCurrentPhoto,
            icon: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      widget.photos[index].url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 40,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (caption != null && caption.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              color: Colors.black,
              child: Text(
                caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MemoryPhotoPreviewScreen extends StatelessWidget {
  final List<int> bytes;

  const MemoryPhotoPreviewScreen({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.memory(
            bytes is Uint8List ? bytes as Uint8List : Uint8List.fromList(bytes),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
