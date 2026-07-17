import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({
    super.key,
    required this.name,
    required this.hasChecklist,
  });

  final String name;
  final bool hasChecklist;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $name 👋",
                style:
                    textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                hasChecklist
                    ? "Here's your overview"
                    : "Stay organized, stay ahead!",
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Decorative plant + clipboard illustration on the right.
        // Replace the path below with your actual asset from pubspec.yaml.
        Image.asset(
          'assets/images/overview_plant.png',
          height: 78,
          width: 78,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}