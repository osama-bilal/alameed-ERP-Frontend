// ...existing code...
import 'package:flutter/material.dart';

class MyHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final Widget? avatar;
  final bool showNotifications;
  final bool showProfile;
  final VoidCallback? onMenuPressed;
  final List<Widget>? extraActions;

  const MyHeader({
    super.key,
    this.userName = 'Josiah',
    this.avatar,
    this.showNotifications = true,
    this.showProfile = true,
    this.onMenuPressed,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 1100;

   
    final defaultAvatar =
        avatar ??
        const CircleAvatar(
          backgroundImage: AssetImage("assets/logo/logo-no-background.png"),
        );

    final actions = <Widget>[
      if (showNotifications && !isCompact)
        IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
      if (showProfile && !isCompact)
        IconButton(icon: const Icon(Icons.person), onPressed: () {}),
      Padding(padding: const EdgeInsets.only(right: 8.0), child: defaultAvatar),
      if (extraActions != null) ...extraActions!,
    ];

    return AppBar(
      title: Text(
        'Welcome, $userName',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ),
      ],
    );
  }

  @override
  // preferredSize should be a constant; allow a little extra height for two-line title
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
// ...existing code...