import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:flutter/material.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            QuickActionCard(
              icon: Icons.add_task,
              title: "New\nChecklist",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createChecklist,
                  arguments: {
                    "mode": ChecklistMode.create,
                    "showSkip": false
                  },
                );
              },
            ),

            const SizedBox(width: 14),

            QuickActionCard(
              icon: Icons.description_outlined,
              title: "Templates",
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            QuickActionCard(
              icon: Icons.search,
              title: "Search",
              onTap: () {},
            ),

            const SizedBox(width: 14),

            QuickActionCard(
              icon: Icons.more_horiz,
              title: "More",
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}