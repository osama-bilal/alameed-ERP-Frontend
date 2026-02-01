import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/dataPages/reports.dart';
import '/widgets/permission_guard.dart';
import '/widgets/shared_content.dart';
import '/widgets/tabs_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [l10n.reports];

    Widget desktopView = SharedContent(
      activeScreen: "reports",
      child: AnyPermissionGuard(
        tables: ['report'],
        fallback: Center(child: Text(l10n.cantAccessPage)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                MyContainer(
                  child: MyTabsBar(
                    pageController: _pageController,
                    tabs: tabs,
                    tablesName: ['report'],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(maxHeight: 750),
                  child: PageView(
                    allowImplicitScrolling: true,
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      if (tablePermissions(
                        context,
                        'report',
                      ).values.any((hasPermission) => hasPermission))
                        ReportsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return desktopView;
  }
}
