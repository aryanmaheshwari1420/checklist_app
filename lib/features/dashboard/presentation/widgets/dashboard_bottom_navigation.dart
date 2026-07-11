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
      padding: EdgeInsets.all(8), // let SafeArea control the inner spacing
      child: SafeArea(
        top: false, // only care about bottom inset (home indicator / gesture bar)
        child: SizedBox(
          height: 64, // slightly reduced so icon+text+padding fit comfortably
          child: Row(
            children: [
              _buildItem(
                context: context,
                index: 0,
                icon: Icons.home_filled,
                label: "Dashboard",
              ),
              _buildItem(
                context: context,
                index: 1,
                icon: Icons.description_outlined,
                label: "Templates",
              ),
              const Spacer(),
              _buildItem(
                context: context,
                index: 2,
                icon: Icons.search,
                label: "Search",
              ),
              _buildItem(
                context: context,
                index: 3,
                icon: Icons.more_horiz,
                label: "More",
              ),
            ],
          ),
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

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4), // reduced from 6
          child: Column(
            mainAxisSize: MainAxisSize.min, // don't force extra height
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20, // slightly smaller
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.0, // tighter line height, avoids extra vertical space
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}