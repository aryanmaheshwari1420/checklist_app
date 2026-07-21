import 'package:flutter/material.dart';

/// Reusable error state with a retry action — used across screens that
/// watch a StreamProvider/FutureProvider, so failures (e.g. offline,
/// permission errors) give the user a clear way to recover instead of
/// a raw error message with no path forward.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts a raw error into a short, user-friendly message. Falls back
/// to a generic message rather than showing raw exception text (which
/// often includes stack-trace-like noise or Firestore internals).
String friendlyErrorMessage(Object error) {
  final text = error.toString().toLowerCase();

  if (text.contains('not found')) {
    return "This item couldn't be found. It may have been deleted.";
  }
  if (text.contains('network') ||
      text.contains('unavailable') ||
      text.contains('timeout')) {
    return "Check your internet connection and try again.";
  }
  if (text.contains('permission') || text.contains('denied')) {
    return "You don't have permission to view this.";
  }

  return "Please check your connection and try again.";
}