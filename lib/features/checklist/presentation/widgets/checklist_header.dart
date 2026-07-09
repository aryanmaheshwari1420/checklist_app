import 'package:checklist_app/shared/models/checklist_model.dart';
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
    int total = 0;
    int completed = 0;

    for (final items in checklist.items.values) {
      total += items.length;

      completed += items.where((item) => item.checked).length;
    }

    return total == 0 ? 0.0 : completed / total;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Due Date + Priority
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey,
            ),

            const SizedBox(width: 6),

            Text(
              "Due: ${getDueDateText(checklist.dueDate)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    checklist.priority,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        /// Category + Completion
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xffF1EDFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                checklist.type,
                style: TextStyle(
                  color: Color(0xff5B3DF5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            const Text("•", style: TextStyle(color: Colors.grey, fontSize: 18)),

            const SizedBox(width: 12),

            Text(
              "${(calculateChecklistProgress(checklist) * 100).toInt()}% Completed",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
