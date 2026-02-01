import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/dataPages/purch_invoice.dart';
import '/widgets/dataPages/purch_return.dart';
import '/widgets/permission_guard.dart';
import '/widgets/shared_content.dart';
import '/widgets/tabs_bar.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<PurchaseScreen> createState() => PurchaseScreenState();
}

class PurchaseScreenState extends State<PurchaseScreen> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [l10n.purchases, l10n.returns];

    Widget desktopView = SharedContent(
      activeScreen: "purchases",
      child: AnyPermissionGuard(
        tables: ['purchaseinvoice', 'returnpurchase'],
        fallback: Center(child: Text(l10n.cantAccessPage)),
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
                    tablesName: ['purchaseinvoice', 'returnpurchase'],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(maxHeight: 750),
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
