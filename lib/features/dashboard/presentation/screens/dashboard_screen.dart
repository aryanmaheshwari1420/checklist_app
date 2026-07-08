import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/greeting_section.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/overall_progress_card.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/recent_checklist_card.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Later this will come from Firebase
    const bool hasChecklist = false;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: DashboardAppBar(
        onMenuTap: () {},
        onNotificationTap: () {},
        hasNotification: false,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B3DF5),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateCheckListScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: DashboardBottomNavigation(
        currentIndex: 0,
        onTap: (index) {},
        onFabPressed: () {},
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingSection(name: "Aryan", hasChecklist: hasChecklist),

              const SizedBox(height: 25),

              Row(
                children: const [
                  SummaryCard(
                    title: "Total\nChecklists",
                    value: 0,
                    icon: Icons.assignment_outlined,
                    iconColor: Colors.deepPurple,
                  ),

                  SummaryCard(
                    title: "Completed",
                    value: 0,
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                  ),

                  SummaryCard(
                    title: "Pending",
                    value: 0,
                    icon: Icons.access_time,
                    iconColor: Colors.orange,
                  ),

                  SummaryCard(
                    title: "Overdue",
                    value: 0,
                    icon: Icons.calendar_today_outlined,
                    iconColor: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [
                    const OverallProgressCard(
                      progress: .68,
                      completed: 12,
                      total: 18,
                    ),

                    const SizedBox(height: 28),

                    const QuickActionsSection(),

                    const SizedBox(height: 100),

                    const Text(
                      "Recent Checklists",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    RecentChecklistCard(
                      title: "Travel Checklist",
                      completed: 12,
                      total: 18,
                      status: "In Progress",
                      onTap: () {},
                    ),

                    RecentChecklistCard(
                      title: "Office Setup",
                      completed: 18,
                      total: 18,
                      status: "Completed",
                      onTap: () {},
                    ),

                    RecentChecklistCard(
                      title: "Shopping List",
                      completed: 2,
                      total: 10,
                      status: "Pending",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
