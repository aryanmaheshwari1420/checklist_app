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
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(
              Color(0xff5B3DF5),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}