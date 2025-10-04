import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'drawer.dart';

class SharedContent extends StatelessWidget {
  const SharedContent({
    super.key,
    required this.child,
    required this.activeScreen,
    this.actions = const [],
    this.floatingActionButton,
  });
  final List<Widget> actions;
  final Widget child;
  final String activeScreen;
  final FloatingActionButton? floatingActionButton;
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width > 1100;
    return Scaffold(
      appBar: MyHeader(extraActions: actions),
      backgroundColor: Colors.grey[200],
      drawer: !isDesktop
          ? Drawer(child: MyDrawer(activePage: activeScreen))
          : null,
      body: Row(
        children: [
          // الشريط الجانبي: يظهر فقط على الشاشات الكبيرة
          if (isDesktop) MyDrawer(activePage: activeScreen),
          // المحتوى الرئيسي
          Expanded(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
