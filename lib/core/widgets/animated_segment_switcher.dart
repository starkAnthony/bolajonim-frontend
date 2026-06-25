import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Two-or-more-option switcher with a sliding pill indicator.
class AnimatedSegmentSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String> labels;
  final Duration duration;

  const AnimatedSegmentSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.labels,
    this.duration = const Duration(milliseconds: 320),
  }) : assert(labels.length >= 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;

          return SizedBox(
            height: 52,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedPositioned(
                  duration: duration,
                  curve: Curves.easeInOutCubic,
                  left: selectedIndex * segmentWidth,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: List.generate(labels.length, (index) {
                    final isSelected = selectedIndex == index;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (index != selectedIndex) {
                              onChanged(index);
                            }
                          },
                          borderRadius: BorderRadius.circular(18),
                          splashColor: Colors.white24,
                          highlightColor: Colors.white10,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: duration,
                              curve: Curves.easeInOutCubic,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              child: Text(labels[index]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Fade + slide transition for swapping form sections.
class SegmentContentTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SegmentContentTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? const SizedBox.shrink();
      },
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
