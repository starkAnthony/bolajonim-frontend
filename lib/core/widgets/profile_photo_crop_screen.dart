import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Lets the user move, zoom, and rotate a photo inside a square frame
/// before it is saved as the profile picture.
class ProfilePhotoCropScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ProfilePhotoCropScreen({super.key, required this.imageBytes});

  @override
  State<ProfilePhotoCropScreen> createState() => _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  ui.Image? _image;
  bool _failed = false;
  bool _saving = false;
  double _scale = 1;
  double _gestureStartScale = 1;
  Offset _offset = Offset.zero;
  int _quarterTurns = 0;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.imageBytes);
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  double _cropSize(BoxConstraints constraints) {
    final side = math.min(constraints.maxWidth - 32, constraints.maxHeight - 24);
    return side.clamp(220.0, 460.0);
  }

  _CropFrame _frame(double crop) {
    final image = _image!;
    final turns = _quarterTurns % 4;
    final swapped = turns.isOdd;
    final srcW = swapped ? image.height.toDouble() : image.width.toDouble();
    final srcH = swapped ? image.width.toDouble() : image.height.toDouble();
    final cover = math.max(crop / srcW, crop / srcH) * _scale;
    final displayW = srcW * cover;
    final displayH = srcH * cover;
    final held = _clampedOffset(_offset, crop: crop);
    return _CropFrame(
      left: (crop - displayW) / 2 + held.dx,
      top: (crop - displayH) / 2 + held.dy,
      displayW: displayW,
      displayH: displayH,
      turns: turns,
    );
  }

  Offset _clampedOffset(Offset raw, {double? crop}) {
    final image = _image;
    final side = crop ?? _lastCrop;
    if (image == null || side <= 0) return raw;
    final turns = _quarterTurns % 4;
    final swapped = turns.isOdd;
    final srcW = swapped ? image.height.toDouble() : image.width.toDouble();
    final srcH = swapped ? image.width.toDouble() : image.height.toDouble();
    final cover = math.max(side / srcW, side / srcH) * _scale;
    final maxX = math.max(0.0, (srcW * cover - side) / 2);
    final maxY = math.max(0.0, (srcH * cover - side) / 2);
    return Offset(raw.dx.clamp(-maxX, maxX), raw.dy.clamp(-maxY, maxY));
  }

  void _setScale(double next) {
    setState(() => _scale = next.clamp(1.0, 4.0));
  }

  double _lastCrop = 320;

  Future<void> _save() async {
    final image = _image;
    if (image == null || _saving) return;
    setState(() => _saving = true);
    try {
      final bytes = await _export(image, _frame(_lastCrop), _lastCrop);
      if (!mounted) return;
      Navigator.pop(context, bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rasmni tayyorlab bo‘lmadi.')),
      );
    }
  }

  Future<Uint8List> _export(ui.Image image, _CropFrame frame, double crop) async {
    const out = 1080.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.clipRect(const Rect.fromLTWH(0, 0, out, out));
    final factor = out / crop;
    final swapped = frame.turns.isOdd;
    final dstW = (swapped ? frame.displayH : frame.displayW) * factor;
    final dstH = (swapped ? frame.displayW : frame.displayH) * factor;
    canvas.save();
    canvas.translate(
      (frame.left + frame.displayW / 2) * factor,
      (frame.top + frame.displayH / 2) * factor,
    );
    canvas.rotate(frame.turns * math.pi / 2);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromCenter(center: Offset.zero, width: dstW, height: dstH),
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
    final picture = recorder.endRecording();
    final rendered = await picture.toImage(out.toInt(), out.toInt());
    final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
    rendered.dispose();
    if (data == null) {
      throw StateError('empty image');
    }
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121417),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rasmni sozlash',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _failed
          ? const Center(
              child: Text(
                'Rasm ochilmadi.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : _image == null
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                      child: Text(
                        'Rasmni suring, kattalashtiring yoki aylantiring',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, stage) {
                          final crop = _cropSize(stage);
                          _lastCrop = crop;
                          final frame = _frame(crop);
                          final cropLeft = (stage.maxWidth - crop) / 2;
                          final cropTop = (stage.maxHeight - crop) / 2;
                          return GestureDetector(
                            onDoubleTap: () => _setScale(_scale > 1.05 ? 1 : 2),
                            onScaleStart: (_) => _gestureStartScale = _scale,
                            onScaleUpdate: (details) {
                              setState(() {
                                _scale = (_gestureStartScale * details.scale)
                                    .clamp(1.0, 4.0);
                                _offset = _clampedOffset(
                                  _offset + details.focalPointDelta,
                                );
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Positioned(
                                  left: cropLeft + frame.left,
                                  top: cropTop + frame.top,
                                  width: frame.displayW,
                                  height: frame.displayH,
                                  child: _RotatedPhoto(
                                    image: _image!,
                                    frame: frame,
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _CropShadePainter(
                                        hole: RRect.fromRectAndRadius(
                                          Rect.fromLTWH(cropLeft, cropTop, crop, crop),
                                          Radius.circular(crop * 0.18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Row(
                            children: [
                              _RoundTool(
                                icon: Icons.rotate_left_rounded,
                                onTap: _saving
                                    ? null
                                    : () => setState(() {
                                          _quarterTurns = (_quarterTurns + 3) % 4;
                                          _offset = Offset.zero;
                                        }),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _scale,
                                  min: 1,
                                  max: 4,
                                  activeColor: AppColors.primary,
                                  onChanged: _saving ? null : _setScale,
                                ),
                              ),
                              _RoundTool(
                                icon: Icons.rotate_right_rounded,
                                onTap: _saving
                                    ? null
                                    : () => setState(() {
                                          _quarterTurns = (_quarterTurns + 1) % 4;
                                          _offset = Offset.zero;
                                        }),
                              ),
                            ],
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _saving
                                        ? null
                                        : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('Bekor qilish'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saving ? null : _save,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _saving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Saqlash',
                                            style: TextStyle(fontWeight: FontWeight.w700),
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

class _CropFrame {
  final double left;
  final double top;
  final double displayW;
  final double displayH;
  final int turns;

  const _CropFrame({
    required this.left,
    required this.top,
    required this.displayW,
    required this.displayH,
    required this.turns,
  });
}

class _RotatedPhoto extends StatelessWidget {
  final ui.Image image;
  final _CropFrame frame;

  const _RotatedPhoto({required this.image, required this.frame});

  @override
  Widget build(BuildContext context) {
    final swapped = frame.turns.isOdd;
    return RotatedBox(
      quarterTurns: frame.turns,
      child: RawImage(
        image: image,
        width: swapped ? frame.displayH : frame.displayW,
        height: swapped ? frame.displayW : frame.displayH,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _CropShadePainter extends CustomPainter {
  final RRect hole;

  const _CropShadePainter({required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final shade = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(shade, Paint()..color = const Color(0xB3121417));
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
    final grid = Paint()
      ..color = const Color(0x55FFFFFF)
      ..strokeWidth = 1;
    final rect = hole.outerRect;
    for (var i = 1; i <= 2; i++) {
      final dx = rect.left + rect.width * i / 3;
      final dy = rect.top + rect.height * i / 3;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), grid);
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _CropShadePainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}

class _RoundTool extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundTool({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2E33),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
