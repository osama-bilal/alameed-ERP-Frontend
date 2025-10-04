import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/models/product.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/models/salarypayment.dart';
import 'package:ponit_of_sales/models/shift.dart';
import 'package:ponit_of_sales/models/stockmovement.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/models/transections.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/screens/about.dart';
import 'package:ponit_of_sales/screens/accounting.dart';
import 'package:ponit_of_sales/screens/hr2.dart';
import 'package:ponit_of_sales/screens/inventory.dart';
import 'package:ponit_of_sales/screens/pos.dart';
import 'package:ponit_of_sales/screens/purchases.dart';
import 'package:ponit_of_sales/screens/reports.dart';
import 'package:ponit_of_sales/screens/sales.dart';
import 'package:ponit_of_sales/screens/settings.dart';
import 'package:ponit_of_sales/utils/allowed_tabs.dart';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:ponit_of_sales/widgets/screen_card.dart';

import '../models/customer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> allowedTabs;
  @override
  void initState() {
    allowedTabs = allowedHomeTabs(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GeneralBloc<SaleInvoice>()),
        BlocProvider(create: (context) => GeneralBloc<SaleItem>()),
        BlocProvider(create: (context) => GeneralBloc<POSView>()),
        BlocProvider(create: (context) => GeneralBloc<Category>()),
        BlocProvider(create: (context) => GeneralBloc<Attendance>()),
        BlocProvider(create: (context) => GeneralBloc<Customer>()),
        BlocProvider(create: (context) => GeneralBloc<Debt>()),
        BlocProvider(create: (context) => GeneralBloc<DebtPayment>()),
        BlocProvider(create: (context) => GeneralBloc<Deposit>()),
        BlocProvider(create: (context) => GeneralBloc<Employee>()),
        BlocProvider(create: (context) => GeneralBloc<Expense>()),
        BlocProvider(create: (context) => GeneralBloc<PaymentMethod>()),
        BlocProvider(create: (context) => GeneralBloc<SalaryPayment>()),
        BlocProvider(create: (context) => GeneralBloc<Product>()),
        BlocProvider(create: (context) => GeneralBloc<PurchaseInvoice>()),
        BlocProvider(create: (context) => GeneralBloc<PurchaseItem>()),
        BlocProvider(create: (context) => GeneralBloc<ReturnPurchase>()),
        BlocProvider(create: (context) => GeneralBloc<Report>()),
        BlocProvider(create: (context) => GeneralBloc<Shift>()),
        BlocProvider(create: (context) => GeneralBloc<StockMovement>()),
        BlocProvider(create: (context) => GeneralBloc<Supplier>()),
        BlocProvider(create: (context) => GeneralBloc<AccountTransaction>()),
        BlocProvider(create: (context) => GeneralBloc<User>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueAccent,
                  ),
                  padding: EdgeInsets.all(20),
                  height: 200,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Here is whats happen in your shop",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Current Shift Opened at: //${formatDateTimeSmart(DateTime.now())}",
                          ),
                          Text("expected balance: {9999}"),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("{open Shift} ?? {Close Shift}"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    // childAspectRatio: 0.7,
                  ),
                  children: [
                    if (allowedTabs.contains("pos"))
                      ScreenCardWidget(
                        screenToGo: PosScreen(),
                        name: "POS",
                        icon: Icons.point_of_sale,
                      ),
                    if (allowedTabs.contains("sales"))
                      ScreenCardWidget(
                        screenToGo: SalesScreen(initPage: 1),
                        name: "Sales",
                        icon: Icons.shopping_bag,
                      ),
                    if (allowedTabs.contains("accounting"))
                      ScreenCardWidget(
                        screenToGo: AccountingScreen(),
                        name: "Accounting",
                        icon: Icons.account_balance,
                      ),
                    if (allowedTabs.contains("purchase"))
                      ScreenCardWidget(
                        screenToGo: PurchaseScreen(),
                        name: "Purchase",
                        icon: Icons.shopping_cart,
                      ),
                    if (allowedTabs.contains("hr"))
                      ScreenCardWidget(
                        screenToGo: HR2Screen(),
                        name: "HR",
                        icon: Icons.people,
                      ),
                    if (allowedTabs.contains("reports"))
                      ScreenCardWidget(
                        screenToGo: ReportsScreen(),
                        name: "Reports",
                        icon: Icons.leaderboard,
                      ),
                    if (allowedTabs.contains("inventory"))
                      ScreenCardWidget(
                        screenToGo: InventoryScreen(),
                        name: "Inventory",
                        icon: Icons.inventory,
                      ),
                    ScreenCardWidget(
                      screenToGo: SettingsScreen(),
                      name: "Setting",
                      icon: Icons.settings,
                    ),
                    ScreenCardWidget(
                      screenToGo: AboutScreen(),
                      name: "About",
                      icon: Icons.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
