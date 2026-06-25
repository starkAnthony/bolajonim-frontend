import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/report_format_utils.dart';

class ReportWriterHeader extends StatelessWidget {
  final String? writerName;
  final String? writerRole;
  final String? writerPhotoUrl;
  final String? reportDate;
  final String? createdAt;
  final String? weather;

  const ReportWriterHeader({
    super.key,
    this.writerName,
    this.writerRole,
    this.writerPhotoUrl,
    this.reportDate,
    this.createdAt,
    this.weather,
  });

  String get _roleLabel {
    switch ((writerRole ?? '').toLowerCase()) {
      case 'director':
        return 'Direktor';
      case 'teacher':
        return 'O\'qituvchi';
      default:
        return writerRole ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (writerName ?? '').trim();
    if (name.isEmpty) return const SizedBox.shrink();

    final date = ReportFormatUtils.formatReportDate(reportDate);
    final created = ReportFormatUtils.formatTimestamp(createdAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            const Color(0xFFE8F6FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: ReportWeatherAnimation(weather: weather),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 88, 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: writerPhotoUrl != null &&
                          writerPhotoUrl!.trim().isNotEmpty
                      ? NetworkImage(writerPhotoUrl!)
                      : null,
                  child: writerPhotoUrl == null || writerPhotoUrl!.trim().isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 32,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_roleLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(_roleLabel, style: AppTextStyles.bodySmall),
                      ],
                      if (date.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(date, style: AppTextStyles.bodySmall),
                      ],
                      if (created.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Yuborilgan: $created',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportWeatherAnimation extends StatefulWidget {
  final String? weather;

  const ReportWeatherAnimation({super.key, this.weather});

  @override
  State<ReportWeatherAnimation> createState() => _ReportWeatherAnimationState();
}

class _ReportWeatherAnimationState extends State<ReportWeatherAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = (widget.weather ?? 'sunny').toLowerCase();
    return SizedBox(
      width: 72,
      height: 72,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          switch (code) {
            case 'rainy':
              return _RainyWeather(t: _controller.value);
            case 'cloudy':
              return _CloudyWeather(t: _controller.value);
            case 'snowy':
              return _SnowyWeather(t: _controller.value);
            case 'windy':
              return _WindyWeather(t: _controller.value);
            default:
              return _SunnyWeather(t: _controller.value);
          }
        },
      ),
    );
  }
}

class _SunnyWeather extends StatelessWidget {
  final double t;

  const _SunnyWeather({required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: t * math.pi * 2,
          child: Icon(
            Icons.wb_sunny_rounded,
            size: 42,
            color: Colors.orange.shade400,
          ),
        ),
      ],
    );
  }
}

class _CloudyWeather extends StatelessWidget {
  final double t;

  const _CloudyWeather({required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(math.sin(t * math.pi * 2) * 4, 0),
          child: const Icon(
            Icons.cloud_rounded,
            size: 44,
            color: Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }
}

class _RainyWeather extends StatelessWidget {
  final double t;

  const _RainyWeather({required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.cloud_rounded, size: 36, color: Color(0xFF78909C)),
        ...List.generate(3, (i) {
          final phase = (t + i * 0.2) % 1.0;
          return Positioned(
            left: 22 + i * 10.0,
            top: 34 + phase * 18,
            child: Icon(
              Icons.water_drop_rounded,
              size: 12,
              color: Colors.blue.shade300.withValues(alpha: 0.9),
            ),
          );
        }),
      ],
    );
  }
}

class _SnowyWeather extends StatelessWidget {
  final double t;

  const _SnowyWeather({required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.ac_unit_rounded, size: 34, color: Color(0xFF81D4FA)),
        ...List.generate(4, (i) {
          final phase = (t + i * 0.15) % 1.0;
          return Positioned(
            left: 14 + i * 12.0,
            top: 18 + phase * 28,
            child: const Icon(Icons.circle, size: 4, color: Colors.white),
          );
        }),
      ],
    );
  }
}

class _WindyWeather extends StatelessWidget {
  final double t;

  const _WindyWeather({required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (i) {
        final phase = (t + i * 0.25) % 1.0;
        return Positioned(
          left: 8 + phase * 24,
          top: 24 + i * 10.0,
          child: Icon(
            Icons.air_rounded,
            size: 18,
            color: Colors.teal.shade300,
          ),
        );
      }),
    );
  }
}

class ReportWeatherPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ReportWeatherPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const options = <String>[
    'sunny',
    'cloudy',
    'rainy',
    'snowy',
    'windy',
  ];

  static IconData iconFor(String code) {
    switch (code.toLowerCase()) {
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'rainy':
        return Icons.grain_rounded;
      case 'snowy':
        return Icons.ac_unit_rounded;
      case 'windy':
        return Icons.air_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  static Color colorFor(String code) {
    switch (code.toLowerCase()) {
      case 'cloudy':
        return const Color(0xFF78909C);
      case 'rainy':
        return const Color(0xFF42A5F5);
      case 'snowy':
        return const Color(0xFF81D4FA);
      case 'windy':
        return const Color(0xFF26A69A);
      default:
        return Colors.orange.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ob-havo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((code) {
            final isSelected = selected == code;
            return Semantics(
              label: code,
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: () => onChanged(code),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorFor(code).withValues(alpha: 0.18)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? colorFor(code) : const Color(0xFFE0E6ED),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    iconFor(code),
                    color: colorFor(code),
                    size: 28,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
