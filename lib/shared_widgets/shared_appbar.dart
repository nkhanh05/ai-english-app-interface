import 'package:flutter/material.dart';
import 'constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const CustomAppBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorTeal,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      actions: [
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
