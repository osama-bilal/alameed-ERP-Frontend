import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/returns.dart';
import 'package:ponit_of_sales/widgets/dataPages/sales_invoice.dart';
import 'package:ponit_of_sales/widgets/dataPages/sales.dart';
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

  final tabs = ["Invoices", "Sales", "Returns"];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget desktopView = SharedContent(
      activeScreen: "sales",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              MyContainer(child: MyTabsBar(pageController: _pageController, tabs: tabs,tablesName: ['saleinvoice', 'saleitem', 'returnsale'],),),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: 700),
                child: PageView(
                  allowImplicitScrolling: true,
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SaleInvoicePage(),
                    SaleItemsPage(),
                    SalesReturnPage(),
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
