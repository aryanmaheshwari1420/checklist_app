import 'package:flutter/material.dart';

class ChecklistProgressBar extends StatelessWidget {
  const ChecklistProgressBar({
    super.key,
    this.progress = 0.67,
  });

  /// Value between 0.0 - 1.0
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            // Colors are now handled by the theme's progressIndicatorTheme
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}