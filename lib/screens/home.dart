import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/hr/shift.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/shift.dart';
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
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/widgets/screen_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> allowedTabs;
  late final ShiftController _shiftController;
  @override
  void initState() {
    _shiftController = ShiftController(
      context: context,
      service: AppService.shiftService,
    );
    _shiftController.getOpened();
    allowedTabs = allowedHomeTabs(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              BlocSelector<GeneralBloc<Shift>, GeneralState<Shift>, Shift>(
                selector: (state) {
                  if (state is LoadSinglItemSuccess<Shift>) {
                    return state.item;
                  }
                  if (state is ItemOperationSuccess<Shift> &&
                      state.operation != OperationType.delete) {
                    return state.item!;
                  }
                  if (state is GeneralLoadInProgress<Shift> ||
                      state is ItemOperationGoing<Shift>) {
                    return Shift(openingBalance: "Loading");
                  }
                  return Shift(openingBalance: "");
                },
                builder: (context, state) {
                  // if (state.isClosed || state.openedAt == null) {
                  // return Center(child: Text("there is an error while get"),)
                  // }
                  if (state.openingBalance == "Loading") {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            if (state.openedAt != null)
                              Text(
                                "Current Shift Opened at: ${formatDateTimeSmart(state.openedAt)}",
                              ),
                            if (state.openingBalance != "")
                              Text("Open balance: ${state.openingBalance}"),
                          ],
                        ),
                        state.isClosed
                            ? ElevatedButton(
                                onPressed: () {},
                                child: Text("open Shift"),
                              )
                            : ElevatedButton(
                                onPressed: () {},
                                child: Text("Close Shift"),
                              ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
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
    );
  }
}
