import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.onMenuTap,
    required this.onNotificationTap,
    this.hasNotification = false,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      // The AppBar is now fully styled by the theme's `appBarTheme`
      centerTitle: true,
      automaticallyImplyLeading: false,

      leading: IconButton(
        onPressed: onMenuTap,
        // Icon color is inherited from the theme
        icon: const Icon(Icons.menu),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: colorScheme.onPrimary,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          const Text("Action Checklist"),
        ],
      ),

      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: onNotificationTap,
              // Icon color is inherited from the theme
              icon: const Icon(Icons.notifications_none),
            ),

            if (hasNotification)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}