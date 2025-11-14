import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/hr/shift.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/shift.dart';
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
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';
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
    _shiftController = ShiftController(context: context);
    _shiftController.getOpened();
    allowedTabs = allowedHomeTabs(context);
    super.initState();
    context.read<AppParties>().getReady();
  }

  Future<String> showShitDialog(bool isOpen) async {
    String decimal = "";
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isOpen ? "Opening Balance" : "Closing Balance"),
          content: DecimalField(
            hint: "الكاش في الدرج الان",
            onChanged: (value) {
              decimal = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                decimal = "";
                ctx.pop();
              },
              child: Text("cancle"),
            ),
            TextButton(
              onPressed: () {
                ctx.pop();
              },
              child: Text("Continue"),
            ),
          ],
        );
      },
    );
    return decimal;
  }

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>().current;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.primary,
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
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    Text(
                      "Here is whats happen in your shop",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              BlocListener<GeneralBloc<Shift>, GeneralState<Shift>>(
                listener: (context, state) {
                  if (state is GeneralLoadInProgress<Shift> ||
                      state is ItemOperationGoing<Shift>) {
                    context.read<ShiftProvider>().isLoading = true;
                  } else if (state is ItemLoadFailure<Shift>) {
                    context.read<ShiftProvider>().close();
                  } else if (state is LoadSinglItemSuccess<Shift>) {
                    context.read<ShiftProvider>().openNew(state.item);
                  } else if (state is ItemOperationSuccess<Shift> &&
                      state.operation != OperationType.delete) {
                    context.read<ShiftProvider>().openNew(state.item!);
                  }
                },
                child: Builder(
                  builder: (context) {
                    if (context.watch<ShiftProvider>().isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (shift == null ||
                        !context.watch<ShiftProvider>().hasOpen) {
                      return MyContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Please Open Shift first befor do any thing",
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final balance = await showShitDialog(true);
                                if (balance == "") {
                                  return;
                                }
                                _shiftController.open(balance);
                              },
                              child: Text("open Shift"),
                            ),
                          ],
                        ),
                      );
                    }
                    return MyContainer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (shift.openedAt != null)
                                  Text(
                                    "Opened at: ${formatDateTimeSmart(shift.openedAt, showTime: false)}",
                                  ),
                                Text("Open balance: ${shift.openingBalance}"),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final balance = await showShitDialog(true);
                              if (balance == "") {
                                return;
                              }
                              _shiftController.close(shift.id!, balance);
                            },
                            child: Text("Close Shift"),
                          ),
                        ],
                      ),
                    );
                  },
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
                      screenToGo: SalesScreen(),
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
