import 'package:flutter/material.dart';
import 'constants.dart';
import '../state/global_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const CustomAppBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorTeal,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      title: ValueListenableBuilder(
        valueListenable: currentStudentNotifier,
        builder: (context, student, child) {
          final int streakCount = student?.streak ?? 0;
          final bool isMaintained = student?.isStreakMaintained ?? false;

          return Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: isMaintained ? Colors.orange : Colors.blueAccent,
                size: 28,
              ),
              const SizedBox(width: 5),
              Text(
                "$streakCount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: colorOrange, size: 30),
          onPressed: () => debugPrint("Thông báo"),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: colorOrange, size: 35),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
