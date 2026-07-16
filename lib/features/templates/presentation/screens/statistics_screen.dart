import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final textTheme =  Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final stats = {
      'total': 27,
      'completed': 24,
      'pending': 15,
      'critical': 3,
      'priorityDistribution': {
        'High': 12,
        'Medium': 8,
        'Low': 5,
        'Critical': 2,
      },
      'completionTrend': [10.0, 12.0, 14.0, 15.0, 18.0, 20.0, 24.0],
    };

    return Scaffold(
      appBar: AppBar(),
    );
  }
}