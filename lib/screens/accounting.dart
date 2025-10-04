// ddebts,, tansections,, expenses,, deposits,, payrolls,,
import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/dataPages/debt_payment.dart';
import 'package:ponit_of_sales/widgets/dataPages/debts.dart';
import 'package:ponit_of_sales/widgets/dataPages/deposit.dart';
import 'package:ponit_of_sales/widgets/dataPages/expense.dart';
import 'package:ponit_of_sales/widgets/dataPages/payment_methods.dart';
import 'package:ponit_of_sales/widgets/dataPages/payroll.dart';
import 'package:ponit_of_sales/widgets/dataPages/transections.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key, this.initPage = 0});
  final int initPage;

  @override
  State<AccountingScreen> createState() => AccountingScreenState();
}

class AccountingScreenState extends State<AccountingScreen> {
  late PageController _pageController;

  final tabs = [
    "Debts",
    "Debt Payments",
    "Expenses",
    "Deposit",
    "Payroll",
    "Transections",
    "Payment Methods",
  ];
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  constraints: BoxConstraints(maxHeight: 700),
                  child: PageView(
                    
                    allowImplicitScrolling: true,
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      AnyPermissionGuard(tables: ['debt'], child: DebtPage()),
                      AnyPermissionGuard(
                        tables: ['debtpayment'],
                        child: DebtPayPage(),
                      ),
                      AnyPermissionGuard(
                        tables: ['expense'],
                        child: ExpensePage(),
                      ),
                      AnyPermissionGuard(
                        tables: ['deposit'],
                        child: DepositsPage(),
                      ),
                      AnyPermissionGuard(
                        tables: ['salarypayment'],
                        child: SalaryPage(),
                      ),
                      AnyPermissionGuard(
                        tables: ['accounttransaction'],
                        child: TransectionsPage(),
                      ),
                      AnyPermissionGuard(
                        tables: ['paymentmethod'],
                        child: PaymentMethodsPage(),
                      ),
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
