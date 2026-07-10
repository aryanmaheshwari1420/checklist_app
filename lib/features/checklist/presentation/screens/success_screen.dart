import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuccessScreen extends ConsumerWidget {
  final ChecklistMode mode;
  final String checklistId;
  const SuccessScreen({
    super.key,
    required this.checklistId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ref.invalidate(dashboardProvider);

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F7),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Icon(Icons.check, size: 60, color: Colors.green),
                ),

                const SizedBox(height: 40),

                Text(
                  mode == ChecklistMode.create
                      ? "Checklist Created!"
                      : "Checklist Updated!",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  mode == ChecklistMode.create
                      ? "Your checklist has been\ncreated successfully."
                      : "Your checklist has been\nupdated successfully.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5B3DF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                        ref.invalidate(checklistByIdProvider(checklistId));
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChecklistOverviewScreen(checklistId: checklistId),
                        ),
                      );
                    },
                    child: const Text(
                      "View Checklist",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.createChecklist,
                        (route) => false,
                        arguments: {"mode": ChecklistMode.create},
                      );
                    },
                    child: const Text(
                      "Add Another",
                      style: TextStyle(
                        color: Color(0xff5B3DF5),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
