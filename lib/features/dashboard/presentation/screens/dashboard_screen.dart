import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/auth/presentation/providers/current_user_provider.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/greeting_section.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/overall_progress_card.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/recent_checklist_card.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return dashboardAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stack) =>
          Scaffold(body: Center(child: Text(error.toString()))),

      data: (checklists) {
        final hasChecklist = checklists.isNotEmpty;
        final user = currentUserAsync.value;
        final total = checklists.length;

        int completed = 0;
        int pending = 0;
        int totalItems = 0;
        int checkedItems = 0;

        for (final checklist in checklists) {
          int checklistTotal = 0;
          int checklistCompleted = 0;

          for (final items in checklist.items.values) {
            checklistTotal += items.length;
            checklistCompleted += items.where((e) => e.checked).length;
          }

          totalItems += checklistTotal;
          checkedItems += checklistCompleted;

          if (checklistTotal > 0 && checklistCompleted == checklistTotal) {
            completed++;
          } else {
            pending++;
          }
        }

        final overallProgress = totalItems == 0
            ? 0.0
            : checkedItems / totalItems;

        return Scaffold(
          backgroundColor: const Color(0xffF7F7F7),

          appBar: DashboardAppBar(
            onMenuTap: () {},
            onNotificationTap: () {},
            hasNotification: false,
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff5B3DF5),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.createChecklist,
                arguments: {"mode": ChecklistMode.create, "showSkip": false},
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
                  GreetingSection(
                    name: user?.firstName ?? "User",
                    hasChecklist: hasChecklist,
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      SummaryCard(
                        title: "Total\nChecklists",
                        value: total,
                        icon: Icons.assignment_outlined,
                        iconColor: Colors.deepPurple,
                      ),
                      SummaryCard(
                        title: "Completed",
                        value: completed,
                        icon: Icons.check_circle_outline,
                        iconColor: Colors.green,
                      ),
                      SummaryCard(
                        title: "Pending",
                        value: pending,
                        icon: Icons.access_time,
                        iconColor: Colors.orange,
                      ),
                      const SummaryCard(
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
                        OverallProgressCard(
                          progress: overallProgress,
                          completed: checkedItems,
                          total: totalItems,
                        ),

                        const SizedBox(height: 28),

                        const QuickActionsSection(),

                        const SizedBox(height: 28),

                        const Text(
                          "Recent Checklists",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        if (checklists.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text("No checklists created yet."),
                            ),
                          )
                        else
                          ...checklists.map((checklist) {
                            int totalItems = 0;
                            int completedItems = 0;

                            for (final items in checklist.items.values) {
                              totalItems += items.length;
                              completedItems += items
                                  .where((e) => e.checked)
                                  .length;
                            }

                            String status;

                            if (completedItems == totalItems &&
                                totalItems > 0) {
                              status = "Completed";
                            } else if (completedItems == 0) {
                              status = "Pending";
                            } else {
                              status = "In Progress";
                            }

                            return RecentChecklistCard(
                              title: checklist.title,
                              completed: completedItems,
                              total: totalItems,
                              status: status,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChecklistOverviewScreen(
                                      checklistId: checklist.id!,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
