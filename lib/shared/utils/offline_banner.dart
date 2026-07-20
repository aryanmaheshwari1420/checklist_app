// lib/shared/widgets/offline_banner.dart
import 'package:checklist_app/core/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).value ?? true;

    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.orange.shade700,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        "You're offline — changes will sync when back online",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}