import 'package:flutter/material.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';

class MyTabsBar extends StatefulWidget {
  const MyTabsBar({
    super.key,
    required this.pageController,
    required this.tabs,
    required this.tablesName,
  }) : assert(tabs.length == tablesName.length);
  final PageController pageController;
  final List<String> tabs;
  final List<String> tablesName;
  @override
  State<MyTabsBar> createState() => _MyTabsBarState();
}

class _MyTabsBarState extends State<MyTabsBar> {
  late String selectedTab;
  @override
  void initState() {
    for (var table in widget.tablesName) {
      if (!tablePermissions(
        context,
        table,
      ).values.any((hasPermission) => hasPermission)) {
        if (widget.tablesName.remove(table)) {
          widget.tabs.removeAt(widget.tablesName.indexOf(table));
        }
      }
    }
    selectedTab = widget.tabs[widget.pageController.initialPage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var table in widget.tablesName)
            Builder(
              builder: (context) {
                final tab = widget.tabs[widget.tablesName.indexOf(table)];
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
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                              child: Text(tab),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              margin: const EdgeInsets.only(top: 5),
                              height: isSelected ? 2 : 0,
                              width: isSelected ? 40 : 0,
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
