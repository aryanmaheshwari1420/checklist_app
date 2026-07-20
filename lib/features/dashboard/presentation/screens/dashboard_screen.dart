import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/auth/presentation/providers/current_user_provider.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/greeting_section.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/overall_progress_card.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/recent_checklist_card.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:checklist_app/shared/utils/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int _dashboardChecklistPreviewCount = 4;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _imageForType(String type) {
    switch (type) {
      case "Travel":
        return "assets/images/Traveli.png";
      case "Finance":
        return "assets/images/financei.png";
      case "Vehicle":
        return "assets/images/vehiclei.png";
      case "Event":
        return "assets/images/Eventi.png";
      case "Personal":
        return "assets/images/personali.png";
      case "Charity":
        return "assets/images/Charityi.png";
      case "Split":
        return "assets/images/Spliti.png";
      case "Vendor":
        return "assets/images/Vendori.png";
      case "Other":
        return "assets/images/other_twoi.png";
      default:
        return "assets/images/other_twoi.png";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
        int overdue = 0;

        final today = DateTime.now();
        final todayOnly = DateTime(today.year,today.month,today.day);

        // Calculate

        for (final checklist in checklists) {
          int checklistTotal = 0;
          int checklistCompleted = 0;

          for (final items in checklist.items.values) {
            checklistTotal += items.length;
            checklistCompleted += items.where((e) => e.checked).length;
          }

          totalItems += checklistTotal;
          checkedItems += checklistCompleted;

          final isCompleted =  checklistTotal > 0 && checklistCompleted == checklistTotal;


          if (isCompleted) {
            completed++;
          } else {
            pending++;
          }

          if(!isCompleted && checklist.dueDate!=null){
            final dueDateOnly =  DateTime(
              checklist.dueDate!.year,
              checklist.dueDate!.month,
              checklist.dueDate!.day
            );
            if(dueDateOnly.isBefore(todayOnly)){
            overdue++;
          }
          }
        }

        final overallProgress = totalItems == 0
            ? 0.0
            : checkedItems / totalItems;

        // Only preview the first N checklists on the dashboard itself.
        final previewChecklists = checklists
            .take(_dashboardChecklistPreviewCount)
            .toList();
        final hasMoreChecklists =
            checklists.length > _dashboardChecklistPreviewCount;

        return Scaffold(
          // The background color and AppBar style are now handled by the theme
          appBar: DashboardAppBar(
            onMenuTap: () {},
            onNotificationTap: () {},
            hasNotification: false,
          ),

          // The FAB is now styled by the theme's `floatingActionButtonTheme`
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createChecklist,
                  arguments: {"mode": ChecklistMode.create, "showSkip": false},
                );
              },
              child: const Icon(Icons.add, size: 24),
            ),
          ),

          bottomNavigationBar: DashboardBottomNavigation(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 1: // Templates
                  Navigator.pushNamed(context, AppRoutes.templatesList);
                  break;
                case 2: // Search
                  Navigator.pushNamed(context, AppRoutes.search);
                  break;
                // index 3 = "More" — wire when that screen is ready
              }
            },
            onFabPressed: () {},
          ),

          body: SafeArea(
            child: Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      GreetingSection(
                        name: user?.firstName ?? "User",
                        hasChecklist: hasChecklist,
                      ),
                  
                      const SizedBox(height: 25),
                  
                      Row(
                        children: [
                          SummaryCard(
                            title: "Total",
                            value: total,
                            icon: Icons.assignment_outlined,
                            iconColor: colorScheme.primary,
                            illustrationAsset: 'assets/images/completed.png',
                          ),
                          const SizedBox(width: 8),
                          SummaryCard(
                            title: "Completed",
                            value: completed,
                            icon: Icons.check_circle_outline,
                            iconColor: colorScheme.tertiary,
                            illustrationAsset: 'assets/images/line_chart.png',
                          ),
                          const SizedBox(width: 8),
                          SummaryCard(
                            title: "Pending",
                            value: pending,
                            icon: Icons.access_time,
                            iconColor: Colors.orange,
                            illustrationAsset: 'assets/images/bar_chart.png',
                          ),
                          const SizedBox(width: 8),
                          SummaryCard(
                            title: "Overdue",
                            value: overdue,
                            icon: Icons.calendar_today_outlined,
                            iconColor: colorScheme.error,
                            illustrationAsset: 'assets/images/warning_icon.png',
                          ),
                        ],
                      ),
                  
                      const SizedBox(height: 30),
                  
                      OverallProgressCard(
                        progress: overallProgress,
                        completed: checkedItems,
                        total: totalItems,
                      ),
                  
                      const SizedBox(height: 28),
                  
                      const QuickActionsSection(),
                  
                      const SizedBox(height: 28),
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Active Checklists", style: textTheme.titleLarge),
                          // Only show "View All" when there's actually more to see.
                          if (hasMoreChecklists)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.viewAllChecklist,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Text(
                                  "View All",
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  
                      const SizedBox(height: 18),
                  
                      if (checklists.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: Text("No checklists created yet.")),
                        )
                      else
                        ...previewChecklists.map((checklist) {
                          int totalItems = 0;
                          int completedItems = 0;
                  
                          for (final items in checklist.items.values) {
                            totalItems += items.length;
                            completedItems += items.where((e) => e.checked).length;
                          }
                  
                          String status;
                  
                          if (completedItems == totalItems && totalItems > 0) {
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
                            imagePath: _imageForType(checklist.type),
                            dueDate: checklist.dueDate,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.viewChecklist,
                                arguments: {
                                  'checklistId': checklist.id,
                                  'camefromViewAll': false,
                                }
                              );
                            },
                            onDelete: () async {
                              await ref
                                  .read(checklistControllerProvider.notifier)
                                  .deleteChecklist(checklist.id);
                  
                              ref.invalidate(dashboardProvider);
                  
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Checklist deleted successfully."),
                                  ),
                                );
                              }
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
