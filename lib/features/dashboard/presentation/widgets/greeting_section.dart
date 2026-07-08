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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, $name 👋",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          hasChecklist
              ? "Here's your overview"
              : "Stay organized, stay ahead!",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}