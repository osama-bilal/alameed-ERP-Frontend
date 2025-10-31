import 'package:flutter/material.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/returns.dart';
import 'package:ponit_of_sales/widgets/dataPages/sales_invoice.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<SalesScreen> createState() => SalesScreenState();
}

class SalesScreenState extends State<SalesScreen> {
  late PageController _pageController;

  final tabs = ["Invoices", "Returns"];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget desktopView = SharedContent(
      activeScreen: "sales",
      child: AnyPermissionGuard(
        tables: ['saleinvoice', 'returnsale'],
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
                    tablesName: ['saleinvoice', 'returnsale'],
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
                        'saleinvoice',
                      ).values.any((hasPermission) => hasPermission))
                        SaleInvoicePage(),
                      if (tablePermissions(
                        context,
                        'returnsale',
                      ).values.any((hasPermission) => hasPermission))
                        SalesReturnPage(),
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
