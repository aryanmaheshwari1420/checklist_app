import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/templates/presentation/providers/template_provider.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateOverviewScreen extends ConsumerWidget {
  final String templateId;

  const TemplateOverviewScreen({super.key, required this.templateId});

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

  @override
@override
Widget build(BuildContext context, WidgetRef ref) {
  final templateAsync = ref.watch(templateByIdProvider(templateId));
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  return templateAsync.when(
    loading: () =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
    error: (error, _) => Scaffold(
      body: Center(
        child: Text(
          error.toString().contains('not found')
              ? "Template not found."
              : error.toString(),
        ),
      ),
    ),
    data: (template) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            // ---- Full-bleed header image with floating back button ----
            Stack(
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Image.asset(
                      _imageForType(template.type),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.primaryContainer,
                          alignment: Alignment.center,
                          child: Icon(
                            _iconForType(template.type),
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  child: _circleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                // Positioned(
                //   top: MediaQuery.of(context).padding.top + 12,
                //   right: 16,
                //   child: _circleIconButton(
                //     icon: Icons.notifications_none,
                //     onTap: () {},
                //   ),
                // ),
              ],
            ),

            // ---- Rest of the scrollable content ----
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          template.type,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${template.totalCategories} Categories • ${template.totalItems} Items",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (template.description.isNotEmpty) ...[
                    Text("Description", style: textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Text(
                      template.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    "Categories (${template.totalCategories})",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),


                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: template.categories.length,
                    itemBuilder: (context, index) {
                      final category = template.categories[index];
                      final categoryItems = template.items[category] ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: ExpansionTile(
                          initiallyExpanded: index == 0,
                          title: Text(
                            "$category (${categoryItems.length})",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          children: [
                            if (categoryItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(
                                  "No items in this category",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            else
                              ...categoryItems.map(
                                (itemTitle) => ListTile(
                                  leading: Icon(
                                    Icons.circle_outlined,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  title: Text(itemTitle),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Use Template"),
                onPressed: () {
                  ref
                      .read(checklistControllerProvider.notifier)
                      .loadFromTemplate(template);

                  final tempChecklist = ChecklistModel(
                    id: '',
                    title: template.title,
                    description: template.description,
                    dueDate: null,
                    type: template.type,
                    priority: 'Medium',
                    reminderEnabled: false,
                    reminderDateTime: null,
                    notes: '',
                    categories: template.categories,
                    items: template.items.map(
                      (category, itemTitles) => MapEntry(
                        category,
                        itemTitles
                            .map((title) =>
                                ChecklistItem(title: title, checked: false))
                            .toList(),
                      ),
                    ),
                  );

                  Navigator.pushNamed(
                    context,
                    AppRoutes.createChecklist,
                    arguments: {
                      "mode": ChecklistMode.create,
                      "showSkip": false,
                      "checklist": tempChecklist,
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ---- Small circular floating icon button (back / bell) ----
Widget _circleIconButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return ClipOval(
    child: Material(
      color: Colors.black.withOpacity(0.55),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    ),
  );
}
}
