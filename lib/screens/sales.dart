import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/dataPages/returns.dart';
import '/widgets/dataPages/sales_invoice.dart';
import '/widgets/permission_guard.dart';
import '/widgets/shared_content.dart';
import '/widgets/tabs_bar.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<SalesScreen> createState() => SalesScreenState();
}

class SalesScreenState extends State<SalesScreen> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [l10n.invoices, l10n.returns];

    Widget desktopView = SharedContent(
      activeScreen: "sales",
      child: AnyPermissionGuard(
        tables: ['saleinvoice', 'returnsale'],
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
                    tablesName: ['saleinvoice', 'returnsale'],
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
