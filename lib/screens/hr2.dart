import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/attendace.dart';
import 'package:ponit_of_sales/widgets/dataPages/customer.dart';
import 'package:ponit_of_sales/widgets/dataPages/employee.dart';
import 'package:ponit_of_sales/widgets/dataPages/shifts.dart';
import 'package:ponit_of_sales/widgets/dataPages/supplier.dart';
import 'package:ponit_of_sales/widgets/dataPages/users.dart';
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
    Widget desktopView = SharedContent(
      activeScreen: "hr",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              MyContainer(
                child: MyTabsBar(pageController: _pageController, tabs: tabs),
              ),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: 700),
                child: PageView(
                  allowImplicitScrolling: true,
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    CustomersPage(),
                    SuppliersPage(),
                    EmployeePage(),
                    AttendancePage(),
                    ShiftsPage(),
                    UsersPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return desktopView;
  }
}
