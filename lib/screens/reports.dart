import 'package:flutter/material.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/reports.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  late PageController _pageController;

  final tabs = ["Reports"];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget desktopView = SharedContent(
      activeScreen: "reports",
      child: AnyPermissionGuard(
        tables: ['report'],
        fallback: Center(child: Text("You cant access to this page")),
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
                  constraints: BoxConstraints(maxHeight: 700),
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
