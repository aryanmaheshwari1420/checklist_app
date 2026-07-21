import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:checklist_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChecklistHeader extends StatelessWidget {
  final ChecklistModel checklist;
  const ChecklistHeader({super.key, required this.checklist});

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String getDueDateText(DateTime? dueDate) {
    if (dueDate == null) {
      return "No due date";
    }

    return formatDate(dueDate);
  }

  double calculateChecklistProgress(ChecklistModel checklist) {
     final totalItems = checklist.totalItems;
  final checkedItems = checklist.completedItems;

    return totalItems == 0 ? 0.0 : checkedItems / totalItems;

  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Due Date + Priority
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.textSecondaryLight,
            ),

            const SizedBox(width: 6),

            Text(
              "Due: ${getDueDateText(checklist.dueDate)}",
              style: textTheme.bodyMedium,
            ),

            const Spacer(),

            _buildPriorityChip(context, checklist.priority),
          ],
        ),

        const SizedBox(height: 18),

        /// Category + Completion
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                checklist.type,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text("•",
                style:
                    TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18)),

            const SizedBox(width: 12),

            Text(
              "${(calculateChecklistProgress(checklist) * 100).toInt()}% Completed",
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color color;

    switch (priority) {
      case 'High':
        icon = Icons.local_fire_department_outlined;
        color = colorScheme.error;
        break;
      case 'Medium':
        icon = Icons.flag_outlined;
        color = AppColors.warning;
        break;
      case 'Low':
      default:
        icon = Icons.flag_outlined;
        color = colorScheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            priority,
            style: textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
