import 'package:flutter/material.dart';

class RecentChecklistCard extends StatelessWidget {
  const RecentChecklistCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.status,
    required this.onTap,
  });

  final String title;
  final int completed;
  final int total;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0 : completed / total;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Using a Card which will be styled by the theme's `cardTheme`
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        minHeight: 8,
                        // Colors are now handled by the theme's progressIndicatorTheme
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$completed of $total completed",
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChip(status: status),
                  const SizedBox(height: 28),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    Color color;

    switch (status) {
      case "Completed":
        color = colorScheme.tertiary;
        break;
      case "Pending":
        color = Colors.orange; // Or AppColors.warning
        break;
      default: // In Progress
        color = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
          
