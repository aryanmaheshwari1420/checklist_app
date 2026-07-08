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
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            _buildItem(
              index: 0,
              icon: Icons.home_filled,
              label: "Dashboard",
            ),

            _buildItem(
              index: 1,
              icon: Icons.description_outlined,
              label: "Templates",
            ),

            const Spacer(),

            _buildItem(
              index: 2,
              icon: Icons.search,
              label: "Search",
            ),

            _buildItem(
              index: 3,
              icon: Icons.more_horiz,
              label: "More",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? const Color(0xff5B3DF5)
                    : Colors.grey,
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? const Color(0xff5B3DF5)
                      : Colors.grey,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}