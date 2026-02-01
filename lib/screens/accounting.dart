// ddebts,, tansections,, expenses,, deposits,, payrolls,,
import 'package:flutter/material.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/dataPages/debt_payment.dart';
import '/widgets/dataPages/debts.dart';
import '/widgets/dataPages/deposit.dart';
import '/widgets/dataPages/expense.dart';
import '/widgets/dataPages/payment_methods.dart';
import '/widgets/dataPages/payroll.dart';
import '/widgets/dataPages/transactions.dart';
import '/widgets/permission_guard.dart';
import '/widgets/shared_content.dart';
import '/widgets/tabs_bar.dart';
import '../l10n/app_localizations.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<AccountingScreen> createState() => AccountingScreenState();
}

class AccountingScreenState extends State<AccountingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.debts,
      l10n.debtsPayments,
      l10n.expenses,
      l10n.deposits,
      l10n.payrolls,
      l10n.transactions,
      l10n.paymentMethod,
    ];
    Widget desktopView = SharedContent(
      activeScreen: "accounting",
      child: AnyPermissionGuard(
        tables: [
          'debt',
          'debtpayment',
          'expense',
          'deposit',
          'salarypayment',
          'accounttransaction',
          'paymentmethod',
        ],
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
                    tablesName: [
                      'debt',
                      'debtpayment',
                      'expense',
                      'deposit',
                      'salarypayment',
                      'accounttransaction',
                      'paymentmethod',
                    ],
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
                        'debt',
                      ).values.any((hasPermission) => hasPermission))
                        DebtPage(),
                      if (tablePermissions(
                        context,
                        'debtpayment',
                      ).values.any((hasPermission) => hasPermission))
                        DebtPayPage(),
                      if (tablePermissions(
                        context,
                        'expense',
                      ).values.any((hasPermission) => hasPermission))
                        ExpensePage(),
                      if (tablePermissions(
                        context,
                        'deposit',
                      ).values.any((hasPermission) => hasPermission))
                        DepositsPage(),
                      if (tablePermissions(
                        context,
                        'salarypayment',
                      ).values.any((hasPermission) => hasPermission))
                        SalaryPage(),
                      if (tablePermissions(
                        context,
                        'accounttransaction',
                      ).values.any((hasPermission) => hasPermission))
                        TransectionsPage(),
                      if (tablePermissions(
                        context,
                        'paymentmethod',
                      ).values.any((hasPermission) => hasPermission))
                        PaymentMethodsPage(),
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
