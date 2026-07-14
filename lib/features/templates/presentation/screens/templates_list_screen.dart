import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/templates/presentation/providers/template_provider.dart';
import 'package:checklist_app/shared/models/template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplatesListScreen extends ConsumerStatefulWidget {
  const TemplatesListScreen({super.key});

  @override
  ConsumerState<TemplatesListScreen> createState() =>
      _TemplatesListScreenState();
}

class _TemplatesListScreenState extends ConsumerState<TemplatesListScreen> {
  String _selectedType = "All";

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
      case "Split":
        return Icons.call_split_outlined;
      case "Work":
        return Icons.work_outline;
      case "Shopping":
        return Icons.shopping_cart_outlined;
      case "Health":
        return Icons.favorite_outline;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final templatesAsync = ref.watch(
      templatesByTypeProvider(_selectedType == "All" ? null : _selectedType),
    );
    final typesAsync = ref.watch(templateTypesProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Templates"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.searchTemplates);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ---- Type tabs (dynamic, derived from Firestore data) ----
            typesAsync.when(
              loading: () => const SizedBox(
                height: 40,
                child: Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (types) {
                // If the currently selected type no longer exists in the
                // data (e.g. last template of that type was deleted),
                // fall back to "All" instead of showing an empty list.
                if (!types.contains(_selectedType)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedType = "All");
                  });
                }

                return SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: types.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final selected = _selectedType == type;

                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        selectedColor: colorScheme.primary.withOpacity(0.15),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        checkmarkColor: colorScheme.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ---- Templates list ----
            Expanded(
              child: templatesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (templates) {
                  if (templates.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _TemplateCard(
                        template: template,
                        icon: _iconForType(template.type),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.templateDetails,
                            arguments: {"templateId": template.id},
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              "No Templates Yet!",
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              _selectedType == "All"
                  ? "Templates will appear here once available."
                  : "No templates found for \"$_selectedType\".",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.icon,
    required this.onTap,
  });

  final TemplateModel template;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${template.totalCategories} Categories • ${template.totalItems} Items",
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}