import 'package:flutter/material.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/attendace.dart';
import 'package:ponit_of_sales/widgets/dataPages/customer.dart';
import 'package:ponit_of_sales/widgets/dataPages/employee.dart';
import 'package:ponit_of_sales/widgets/dataPages/shifts.dart';
import 'package:ponit_of_sales/widgets/dataPages/supplier.dart';
import 'package:ponit_of_sales/widgets/dataPages/users.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

class HR2Screen extends StatefulWidget {
  const HR2Screen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<HR2Screen> createState() => HR2ScreenState();
}

class HR2ScreenState extends State<HR2Screen> {
  late PageController _pageController;

  final tabs = [
    "Customers",
    "Suppliers",
    "Employees",
    "Attenance Tracking",
    "Shifts tracking",
    "Users",
  ];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isAdmin(context)) {
      tabs.remove("Users");
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
                  constraints: BoxConstraints(maxHeight: 700),
                  child: PageView(
                    allowImplicitScrolling: true,
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      // for (var table in widget.tablesName)
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
