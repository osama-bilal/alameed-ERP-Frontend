import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/brands.dart';
import 'package:ponit_of_sales/widgets/dataPages/categories.dart';
import 'package:ponit_of_sales/widgets/dataPages/options.dart';
import 'package:ponit_of_sales/widgets/dataPages/products.dart';
import 'package:ponit_of_sales/widgets/dataPages/stock_move.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';
import 'package:provider/provider.dart';

/// products,, brands,, categoties,, movements,,

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  late PageController _pageController;

  final tabs = [
    "Stock movements",
    "Products",
    "Brands",
    "Categories",
    "Options",
  ];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
    context.read<ProductsProvider>().checkList();
  }

  @override
  Widget build(BuildContext context) {
    Widget desktopView = SharedContent(
      activeScreen: "inventory",
      child: AnyPermissionGuard(
        tables: [
          'stockmovement',
          'product',
          'brand',
          'category',
          'optionstype',
          'optionsvalue',
        ],
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
                    tablesName: [
                      'stockmovement',
                      'product',
                      'brand',
                      'category',
                      'optionstype',
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(maxHeight: 800),
                  child: PageView(
                    allowImplicitScrolling: true,
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      if (tablePermissions(
                        context,
                        'stockmovement',
                      ).values.any((hasPermission) => hasPermission))
                        MovementsPage(),
                      if (tablePermissions(
                        context,
                        'product',
                      ).values.any((hasPermission) => hasPermission))
                        ProductsPage(),
                      if (tablePermissions(
                        context,
                        'brand',
                      ).values.any((hasPermission) => hasPermission))
                        BrandsPage(),
                      if (tablePermissions(
                        context,
                        'category',
                      ).values.any((hasPermission) => hasPermission))
                        CategoriesPage(),
                      if (tablePermissions(
                        context,
                        'optionstype',
                      ).values.any((hasPermission) => hasPermission))
                        OptionsPage(),
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
