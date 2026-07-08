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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,

      leading: IconButton(
        onPressed: onMenuTap,
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: const Color(0xff5B3DF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            "Action Checklist",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),

      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: onNotificationTap,
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.black,
              ),
            ),

            if (hasNotification)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
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