import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/dataPages/attendace.dart';
import '/widgets/dataPages/customer.dart';
import '/widgets/dataPages/employee.dart';
import '/widgets/dataPages/shifts.dart';
import '/widgets/dataPages/supplier.dart';
import '/widgets/dataPages/users.dart';
import '/widgets/permission_guard.dart';
import '/widgets/shared_content.dart';
import '/widgets/tabs_bar.dart';

class HR2Screen extends StatefulWidget {
  const HR2Screen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<HR2Screen> createState() => HR2ScreenState();
}

class HR2ScreenState extends State<HR2Screen> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.customers,
      l10n.suppliers,
      l10n.employees,
      l10n.attendances,
      l10n.shifts,
    ];
    if (isAdmin(context)) {
      tabs.add(l10n.users);
    }
    final tables = [
      'customer',
      'supplier',
      'employee',
      'attendance',
      'shift',
      if (isAdmin(context)) 'user',
    ];
    Widget desktopView = SharedContent(
      activeScreen: "hr",
      child: AnyPermissionGuard(
        tables: tables,
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
                    tablesName: tables,
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
                        'customer',
                      ).values.any((hasPermission) => hasPermission))
                        CustomersPage(),
                      if (tablePermissions(
                        context,
                        'supplier',
                      ).values.any((hasPermission) => hasPermission))
                        SuppliersPage(),
                      if (tablePermissions(
                        context,
                        'employee',
                      ).values.any((hasPermission) => hasPermission))
                        EmployeePage(),
                      if (tablePermissions(
                        context,
                        'attendance',
                      ).values.any((hasPermission) => hasPermission))
                        AttendancePage(),
                      if (tablePermissions(
                        context,
                        'shift',
                      ).values.any((hasPermission) => hasPermission))
                        ShiftsPage(),
                      if (isAdmin(context))
                        if (tablePermissions(
                          context,
                          'user',
                        ).values.any((hasPermission) => hasPermission))
                          UsersPage(),
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
