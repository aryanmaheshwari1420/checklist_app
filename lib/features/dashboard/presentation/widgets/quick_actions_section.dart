import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:flutter/material.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            QuickActionCard(
              icon: Icons.add_task,
              title: "New\nChecklist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCheckListScreen(),
                  ),
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