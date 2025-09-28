import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/products.dart';
import 'package:ponit_of_sales/widgets/dataPages/stock_move.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

/// products,, brands,, categoties,, movements,,
///
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  late PageController _pageController;

  final tabs = ["Stock movements", "Products"];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget desktopView = SharedContent(
      activeScreen: "inventory",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              MyContainer(
                child: MyTabsBar(pageController: _pageController, tabs: tabs, tablesName: ['stockmovement','product'],),
              ),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: 700),
                child: PageView(
                  allowImplicitScrolling: true,
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [MovementsPage(), ProductsPage()],
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
