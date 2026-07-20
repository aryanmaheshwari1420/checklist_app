import 'package:flutter/material.dart';

class RecentChecklistCard extends StatelessWidget {
  const RecentChecklistCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.status,
    required this.onTap,
    this.dueDate,
    this.imagePath,
    this.fallbackIcon = Icons.checklist_rtl_outlined,
    this.onDelete,
  });

  final String title;
  final int completed;
  final int total;
  final String status;
  final VoidCallback onTap;
  final DateTime? dueDate;
  final String? imagePath;
  final IconData fallbackIcon;
  final VoidCallback? onDelete;

  bool get _hasItems => total > 0;

  String? get _formattedDueDate {
    if (dueDate == null) return null;

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
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

  Color _statusColor(ColorScheme colorScheme) {
    if (!_hasItems) return colorScheme.onSurfaceVariant;

    switch (status) {
      case "Completed":
        return colorScheme.tertiary;
      case "Pending":
        return Colors.orange;
      case "Overdue":
        return colorScheme.error;
      default: // In Progress
        return colorScheme.primary;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Checklist"),
          content: Text(
            "Are you sure you want to delete '$title'?\n\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final percentage = (progress * 100).round();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme);
    final trackColor = colorScheme.primary.withValues(alpha: 0.15);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Top row: icon, title, due date, status chip, menu ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imagePath != null
                        ? Image.asset(
                            imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                fallbackIcon,
                                color: statusColor,
                                size: 20,
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              fallbackIcon,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_formattedDueDate != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: _isOverdue
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Due: $_formattedDueDate",
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
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_hasItems)
                    _StatusChip(status: status, color: statusColor),
                  if (onDelete != null)
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        offset: const Offset(0,40),
                        onSelected: (value) {
                          if (value == "delete") {
                            _confirmDelete(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "delete",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Delete",
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ---- Progress bar + percentage, or empty state ----
              if (_hasItems) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: trackColor,
                          valueColor: AlwaysStoppedAnimation(statusColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "$percentage%",
                      style: textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "$completed of $total completed",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else
                Row(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "No items added yet",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
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
  const _StatusChip({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
