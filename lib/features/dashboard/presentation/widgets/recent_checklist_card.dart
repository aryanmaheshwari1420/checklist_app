import 'package:flutter/material.dart';

class RecentChecklistCard extends StatelessWidget {
  const RecentChecklistCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.status,
    required this.onTap,
    this.dueDate, // ✅ new optional parameter
  });

  final String title;
  final int completed;
  final int total;
  final String status;
  final VoidCallback onTap;
  final DateTime? dueDate;

  String? get _formattedDueDate {
    if (dueDate == null) return null;

    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    return "${dueDate!.day} ${months[dueDate!.month - 1]}";
  }

  bool get _isOverdue {
    if (dueDate == null) return false;
    if (status == "Completed") return false;

    final today = DateTime.now();
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    return dueDateOnly.isBefore(todayOnly);
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0 : completed / total;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_formattedDueDate != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: _isOverdue
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formattedDueDate!,
                            style: textTheme.bodySmall?.copyWith(
                              color: _isOverdue
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: _isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        minHeight: 8,
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
        color = Colors.orange;
        break;
      default:
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