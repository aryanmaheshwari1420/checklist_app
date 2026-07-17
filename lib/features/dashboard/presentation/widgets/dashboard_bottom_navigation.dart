import 'package:flutter/material.dart';

class DashboardBottomNavigation extends StatelessWidget {
  const DashboardBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabPressed;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gapWidth = (constraints.maxWidth * 0.14).clamp(48.0, 64.0);
            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final barHeight = 64.0 * textScale.clamp(1.0, 1.15);

            return SizedBox(
              height: barHeight,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildItem(
                      context: context,
                      index: 0,
                      icon: Icons.home_filled,
                      label: "Dashboard",
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildItem(
                      context: context,
                      index: 1,
                      icon: Icons.description_outlined,
                      label: "Templates",
                    ),
                  ),
                  SizedBox(width: gapWidth),
                  Expanded(
                    flex: 1,
                    child: _buildItem(
                      context: context,
                      index: 2,
                      icon: Icons.search,
                      label: "Search",
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildItem(
                      context: context,
                      index: 3,
                      icon: Icons.more_horiz,
                      label: "More",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}