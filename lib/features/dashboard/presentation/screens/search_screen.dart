import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:checklist_app/shared/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Returns a short "matched in ..." reason, or null if title itself matched.
  //
  // Note: item-level search was removed — items now live in a Firestore
  // subcollection (per checklist), so matching against item titles here
  // would require an extra query per checklist just to power a dashboard
  // search box, which isn't worth the added reads. Title + category match
  // covers the common case; a dedicated item search can be added later
  // as its own feature if needed.
  String? _matchReason(ChecklistModel checklist, String query) {
    final lowerQuery = query.toLowerCase();

    if (checklist.title.toLowerCase().contains(lowerQuery)) {
      return null; // title match — no extra reason needed
    }

    for (final category in checklist.categories) {
      if (category.name.toLowerCase().contains(lowerQuery)) {
        return "Category: ${category.name}";
      }
    }

    return "no-match"; // sentinel — means nothing matched
  }

  List<_SearchResult> _filterChecklists(
    List<ChecklistModel> checklists,
    String query,
  ) {
    if (query.isEmpty) return [];

    final results = <_SearchResult>[];

    for (final checklist in checklists) {
      final reason = _matchReason(checklist, query);
      if (reason != "no-match") {
        results.add(_SearchResult(checklist: checklist, matchReason: reason));
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search checklists or categories...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          style: textTheme.bodyLarge,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Scaffold(
          body: ErrorState(
            message: friendlyErrorMessage(error),
            onRetry: () => ref.invalidate(dashboardProvider),
          ),
        ),
        data: (checklists) {
          if (_query.isEmpty) {
            return _buildPrompt(
              context,
              icon: Icons.search,
              message: "Search by checklist name or category.",
            );
          }

          final results = _filterChecklists(checklists, _query);

          if (results.isEmpty) {
            return _buildPrompt(
              context,
              icon: Icons.search_off,
              message: "No results found for \"$_query\".",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final checklist = result.checklist;

              // ---- Reads aggregate counters directly — no items
              // subcollection fetch needed here. ----
              final total = checklist.totalItems;
              final completed = checklist.completedItems;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.checklist_rtl_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    checklist.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "$completed of $total completed",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (result.matchReason != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Matched \u2022 ${result.matchReason}",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.viewChecklist,
                      arguments: {
                        "checklistId": checklist.id,
                      },
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
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  final ChecklistModel checklist;
  final String? matchReason;

  _SearchResult({required this.checklist, this.matchReason});
}
