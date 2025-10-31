import 'package:flutter/material.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/purch_invoice.dart';
import 'package:ponit_of_sales/widgets/dataPages/purch_return.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<PurchaseScreen> createState() => PurchaseScreenState();
}

class PurchaseScreenState extends State<PurchaseScreen> {
  late PageController _pageController;

  final tabs = ["Purchases", "Returns"];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget desktopView = SharedContent(
      activeScreen: "purchases",
      child: AnyPermissionGuard(
        tables: ['purchaseinvoice', 'returnpurchase'],
        fallback: Center(child: Text("You cant access to this page")),
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
                      'purchaseinvoice',
                      'returnpurchase',
                    ],
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
                      if (tablePermissions(
                        context,
                        'purchaseinvoice',
                      ).values.any((hasPermission) => hasPermission))
                        PurchaseInvoicePage(),
                      if (tablePermissions(
                        context,
                        'returnpurchase',
                      ).values.any((hasPermission) => hasPermission))
                        ReturnPurchasePage(),
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
