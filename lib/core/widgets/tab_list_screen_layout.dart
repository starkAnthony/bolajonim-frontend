import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Keeps tab title + optional search fixed while only the list scrolls.
class TabListScreenLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? header;
  final Widget body;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry listPadding;

  const TabListScreenLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.header,
    required this.body,
    this.headerPadding = const EdgeInsets.fromLTRB(20, 16, 20, 12),
    this.listPadding = const EdgeInsets.fromLTRB(20, 0, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: headerPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: AppTextStyles.bodySmall),
              ],
              if (header != null) ...[
                const SizedBox(height: 16),
                header!,
              ],
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
