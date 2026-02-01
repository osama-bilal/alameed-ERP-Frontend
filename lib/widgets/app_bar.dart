// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/internet/internet_connect_cubit.dart';

class MyHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final Widget? avatar;
  final bool showNotifications;
  final bool showProfile;
  final VoidCallback? onMenuPressed;
  final List<Widget>? extraActions;

  const MyHeader({
    super.key,
    this.userName = 'Osama',
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
      if (extraActions != null) ...extraActions!,
      if (showNotifications && !isCompact)
        IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
      if (showProfile && !isCompact)
        IconButton(icon: const Icon(Icons.person), onPressed: () {}),
      Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: defaultAvatar,
      ),
    ];

    return BlocBuilder<InternetConnectCubit, InternetConnectState>(
      builder: (context, state) {
        PreferredSizeWidget? bottom;
        if (state is FieldState) {
          bottom = PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              color: Colors.red,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }
        return AppBar(
          title: Text(
            'Welcome, $userName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: bottom,
          leading: isCompact ? null : SizedBox(),
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
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
