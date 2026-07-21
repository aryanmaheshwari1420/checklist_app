import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_items_provider.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/shared/models/ChecklistItemModel%20.dart';
import 'package:checklist_app/shared/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistOverviewScreen extends ConsumerStatefulWidget {
  final String checklistId;
  final bool camefromViewAll;

  const ChecklistOverviewScreen({
    super.key,
    required this.checklistId,
    this.camefromViewAll = false,
  });

  @override
  ConsumerState<ChecklistOverviewScreen> createState() =>
      _ChecklistOverviewScreenState();
}

class _ChecklistOverviewScreenState
    extends ConsumerState<ChecklistOverviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(checklistControllerProvider);
    });
  }

  void editItemDialog(ChecklistItemModel item) {
    final controller = TextEditingController(text: item.title);
    final formKey = GlobalKey<FormState>();

    showBlurDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Item"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            decoration: const InputDecoration(hintText: "Enter item name"),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return "Item name can't be empty";
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final value = controller.text.trim();
              final notifier = ref.read(checklistControllerProvider.notifier);

              await notifier.updateItemTitle(
                checklistId: widget.checklistId,
                itemId: item.id,
                title: value,
              );

              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void deleteItemDialog(ChecklistItemModel item) {
    showBlurDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final notifier = ref.read(checklistControllerProvider.notifier);

              await notifier.deleteItemFromChecklist(
                checklistId: widget.checklistId,
                itemId: item.id,
                wasChecked: item.checked,
              );

              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  String _imageForType(String type) {
    switch (type) {
      case "Travel":
        return "assets/images/Travel.png";
      case "Finance":
        return "assets/images/finance.png";
      case "Vehicle":
        return "assets/images/vehicle.png";
      case "Event":
        return "assets/images/Event.png";
      case "Personal":
        return "assets/images/personal.png";
      case "Charity":
        return "assets/images/Charity.png";
      case "Split":
        return "assets/images/Split.png";
      case "Vendor":
        return "assets/images/Vendor.png";
      case "Other":
        return "assets/images/other_two.png";
      default:
        return "assets/images/Other_two.png";
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case "Travel":
        return Icons.card_travel_outlined;
      case "Finance":
        return Icons.account_balance_wallet_outlined;
      case "Vehicle":
        return Icons.directions_car_outlined;
      case "Personal":
        return Icons.person_outline;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklistAsync = ref.watch(checklistByIdProvider(widget.checklistId));
    final itemsAsync = ref.watch(checklistItemsProvider(widget.checklistId));
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return checklistAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            error.toString().contains('not found')
                ? "Checklist not found."
                : error.toString(),
          ),
        ),
      ),
      data: (checklist) {
        return itemsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) =>
              Scaffold(body: Center(child: Text(error.toString()))),
          data: (items) {
            // ---- Use aggregate counters for the top summary (cheap),
            // but the live items list still drives the actual checklist
            // UI below, so checkbox taps feel instant. ----
            final total = checklist.totalItems;
            final completed = checklist.completedItems;
            final progress = total == 0 ? 0.0 : completed / total;

            // Group items by categoryId for rendering.
            final itemsByCategoryId = <String, List<ChecklistItemModel>>{};
            for (final item in items) {
              itemsByCategoryId.putIfAbsent(item.categoryId, () => []).add(item);
            }

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;

                ref.invalidate(dashboardProvider);
                ref.invalidate(checklistByIdProvider(widget.checklistId));
                ref.invalidate(checklistItemsProvider(widget.checklistId));
                ref.invalidate(checklistControllerProvider);

                if (widget.camefromViewAll) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.dashboard,
                    (route) => false,
                  );
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(checklist.title),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.createChecklist,
                          arguments: {
                            "mode": ChecklistMode.edit,
                            "showSkip": false,
                            "checklistId": widget.checklistId,
                            "checklist": checklist,
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "delete") {
                          showDeleteDialog(ref, context);
                        }
                      },
                      elevation: 4,
                      shadowColor: Colors.black26,
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      offset: const Offset(0, 40),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.delete_outline, color: colorScheme.error),
                              const SizedBox(width: 10),
                              Text(
                                "Delete Checklist",
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addCategories,
                      arguments: {
                        "mode": ChecklistMode.edit,
                        "checklistId": widget.checklistId,
                        "checklist": checklist,
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Category/Item"),
                ),

                body: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: Image.asset(
                            _imageForType(checklist.type),
                            fit: BoxFit.fitWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colorScheme.primaryContainer,
                                alignment: Alignment.center,
                                child: Icon(
                                  _iconForType(checklist.type),
                                  size: 56,
                                  color: colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    checklist.title,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${(progress * 100).round()}%",
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "$completed of $total completed",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 20),

                            _infoRow(
                              context,
                              label: "Due Date",
                              value: checklist.dueDate != null
                                  ? "${checklist.dueDate!.day} ${_monthName(checklist.dueDate!.month)} ${checklist.dueDate!.year}"
                                  : "No due date",
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              context,
                              label: "Priority",
                              value: checklist.priority,
                              valueColor: _priorityColor(
                                checklist.priority,
                                colorScheme,
                              ),
                              showDot: true,
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              context,
                              label: "Type",
                              value: checklist.type,
                              valueColor: colorScheme.primary,
                            ),

                            const SizedBox(height: 20),

                            Text("Description", style: textTheme.labelLarge),
                            const SizedBox(height: 6),
                            Text(
                              checklist.description.isNotEmpty
                                  ? checklist.description
                                  : "No description added.",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Checklist ($total)",
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (checklist.categories.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(
                                  "No categories added yet.",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: checklist.categories.length,
                                itemBuilder: (context, index) {
                                  final category = checklist.categories[index];
                                  final categoryItems =
                                      itemsByCategoryId[category.id] ?? [];
                                  final categoryCompleted = categoryItems
                                      .where((e) => e.checked)
                                      .length;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    child: ExpansionTile(
                                      initiallyExpanded: index == 0,
                                      title: Text(
                                        "${category.name} ($categoryCompleted/${categoryItems.length})",
                                        style: textTheme.titleMedium?.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      children: [
                                        if (categoryItems.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 15,
                                            ),
                                            child: Text(
                                              "No Items Added",
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                color:
                                                    colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ...categoryItems.map((item) {
                                          return CheckboxListTile(
                                            contentPadding:
                                                const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                            ),
                                            value: item.checked,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            onChanged: (value) {
                                              // ---- Now writes ONE field on
                                              // ONE small item document +
                                              // increments the counter — no
                                              // full checklist rewrite. ----
                                              ref
                                                  .read(
                                                    checklistControllerProvider
                                                        .notifier,
                                                  )
                                                  .toggleItemChecked(
                                                    checklistId:
                                                        widget.checklistId,
                                                    itemId: item.id,
                                                    checked: value ?? false,
                                                  );
                                            },
                                            title: Text(item.title),
                                            secondary: PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == "edit") {
                                                  editItemDialog(item);
                                                } else {
                                                  deleteItemDialog(item);
                                                }
                                              },
                                              itemBuilder: (context) => const [
                                                PopupMenuItem(
                                                  value: "edit",
                                                  child: Text("Edit"),
                                                ),
                                                PopupMenuItem(
                                                  value: "delete",
                                                  child: Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 80), // space for FAB
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
      },
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool showDot = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (showDot) ...[
          Icon(Icons.circle, size: 8, color: valueColor ?? colorScheme.primary),
          const SizedBox(width: 6),
        ],
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _priorityColor(String? priority, ColorScheme colorScheme) {
    switch (priority?.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return colorScheme.primary;
    }
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }

  Future<void> showDeleteDialog(WidgetRef ref, BuildContext context) async {
    final confirmed = await showBlurDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Checklist"),
          content: const Text(
            "Are you sure you want to delete this checklist?\n\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await deleteChecklist(ref, context);
  }

  Future<void> deleteChecklist(WidgetRef ref, BuildContext context) async {
    await ref
        .read(checklistControllerProvider.notifier)
        .deleteChecklist(widget.checklistId);

    if (!context.mounted) return;
    ref.invalidate(dashboardProvider);

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (_) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checklist deleted successfully.")),
    );
  }
}