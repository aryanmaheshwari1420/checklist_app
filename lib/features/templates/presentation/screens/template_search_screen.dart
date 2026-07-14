import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/templates/presentation/providers/template_provider.dart';
import 'package:checklist_app/shared/models/template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateSearchScreen extends ConsumerStatefulWidget {
  const TemplateSearchScreen({super.key});

  @override
  ConsumerState<TemplateSearchScreen> createState() =>
      _TemplateSearchScreenState();
}

class _TemplateSearchScreenState extends ConsumerState<TemplateSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<TemplateModel> _filter(List<TemplateModel> templates) {
    if (_query.isEmpty) return [];

    return templates.where((template) {
      if (template.title.toLowerCase().contains(_query)) return true;
      if (template.type.toLowerCase().contains(_query)) return true;

      for (final category in template.categories) {
        if (category.toLowerCase().contains(_query)) return true;
      }

      for (final items in template.items.values) {
        for (final item in items) {
          if (item.toLowerCase().contains(_query)) return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final allTemplatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search templates...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          style: textTheme.bodyLarge,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _searchController.clear(),
            ),
        ],
      ),
      body: allTemplatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (templates) {
          if (_query.isEmpty) {
            return _buildPrompt(
              context,
              icon: Icons.search,
              message: "Search by template name, type, category, or item.",
            );
          }

          final results = _filter(templates);

          if (results.isEmpty) {
            return _buildPrompt(
              context,
              icon: Icons.search_off,
              message: "No templates found for \"$_query\".",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final template = results[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconForType(template.type),
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    template.title,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${template.totalCategories} Categories • ${template.totalItems} Items",
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.templateDetails,
                      arguments: {"templateId": template.id},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPrompt(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              message,
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