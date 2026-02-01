import 'package:flutter/material.dart';
import '/controllers/provider/pos_view.dart';
import '/l10n/app_localizations.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/dataPages/brands.dart';
import '/widgets/dataPages/categories.dart';
import '/widgets/dataPages/options.dart';
import '/widgets/dataPages/products.dart';
import '/widgets/dataPages/stock_move.dart';
import '/widgets/permission_guard.dart';
import '/widgets/shared_content.dart';
import '/widgets/tabs_bar.dart';
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
  late final l10n = AppLocalizations.of(context)!;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
    context.read<ProductsProvider>().checkList();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      l10n.stockMovements,
      l10n.products,
      l10n.brands,
      l10n.categories,
      l10n.options,
    ];
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
