import 'package:flutter/material.dart';

class MyTabsBar extends StatefulWidget {
  const MyTabsBar({
    super.key,
    required this.pageController,
    required this.tabs
  });
  final PageController pageController;
  final List<String> tabs;
  @override
  State<MyTabsBar> createState() => _MyTabsBarState();
}

class _MyTabsBarState extends State<MyTabsBar> {
  late String selectedTab;
  @override
  void initState() {
    selectedTab = widget.tabs[widget.pageController.initialPage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.tabs.map((tab) {
          final isSelected = tab == selectedTab;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = tab;
                  widget.pageController.animateToPage(
                    widget.tabs.indexOf(tab),
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
      ),
    );
  }
}
