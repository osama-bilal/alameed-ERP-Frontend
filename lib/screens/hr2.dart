import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/customer.dart';
import 'package:ponit_of_sales/widgets/dataPages/employee.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';

class HR2Screen extends StatefulWidget {
  const HR2Screen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<HR2Screen> createState() => HR2ScreenState();
}

class HR2ScreenState extends State<HR2Screen> {
  late PageController _pageController;

  final tabs = ["Customers", "Employees", "Attenance Tracking"];
  String selectedTab = "Customers";
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
              MyContainer(child: _buildTabs()),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: 700),
                child: PageView(
                  allowImplicitScrolling: true,
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [CustomersPage(), EmployeePage()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return desktopView;
  }

  Widget _buildTabs() {
    return Row(
      children: tabs.map((tab) {
        final isSelected = tab == selectedTab;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = tab;
                _pageController.animateToPage(
                  tabs.indexOf(tab),
                  curve: Easing.linear,
                  duration: Duration(milliseconds: 500),
                );
              });
            },
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 500),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.lightBlueAccent
                            : Colors.black,
                      ),
                      child: Text(tab),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      margin: const EdgeInsets.only(top: 5),
                      height: 2,
                      width: isSelected ? 40 : 0,
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
