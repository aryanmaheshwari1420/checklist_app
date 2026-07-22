import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getMessage(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';

        case 'not-found':
          return 'The requested checklist no longer exists.';

        case 'unavailable':
          return 'No internet connection. Please try again later.';

        case 'deadline-exceeded':
          return 'The request timed out. Please try again.';

        case 'cancelled':
          return 'The operation was cancelled.';

        case 'already-exists':
          return 'This item already exists.';

        case 'resource-exhausted':
          return 'Service limit reached. Please try again later.';

        case 'unauthenticated':
          return 'Please sign in again.';

        default:
          return error.message ?? 'Something went wrong.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  static void showSnackBar(
    BuildContext context,
    Object error, {
    Color? backgroundColor,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getMessage(error)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.error,
      ),
    );
  }

  static Future<T?> run<T>({
  required BuildContext context,
  required Future<T> Function() action,
  VoidCallback? onSuccess,
}) async {
  try {
    final result = await action();
    onSuccess?.call();
    return result;
  } catch (error, stackTrace) {
    debugPrint('ErrorHandler caught: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (context.mounted) {
      showSnackBar(context, error);
    }
    return null;
  }
}
}
