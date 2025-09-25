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
                  onPageChanged: (value) {
                    // setState(() {
                    selectedTab = tabs[value];
                    // });
                  },

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
              // if (tab == "Customers") {
              setState(() {
                selectedTab = tab;
              });
              _pageController.animateToPage(
                tabs.indexOf(tab),
                curve: Easing.linear,
                duration: Duration(milliseconds: 250),
              );
              // } else {
              //   _pageController.animateToPage(
              //     1,
              //     curve: Easing.linear,
              //     duration: Duration(milliseconds: 250),
              //   );
              // }
            },
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 250),
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
                      duration: Duration(milliseconds: 250),
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
                // if (isSelected)
                //   Container(
                //     margin: const EdgeInsets.only(top: 5),
                //     height: 2,
                //     width: 40,
                //     color: Colors.lightBlueAccent,
                //   ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
