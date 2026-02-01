import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/hr/shift.dart';
import '/controllers/provider/parties.dart';
import '/controllers/provider/shift.dart';
import '/l10n/app_localizations.dart';
import '/models/shift.dart';
// import '/screens/about_screen.dart';
import '/screens/accounting.dart';
import '/screens/hr2.dart';
import '/screens/inventory.dart';
import '/screens/sale%20pos/pos.dart';
import '/screens/purchases.dart';
import '/screens/reports.dart';
import '/screens/sales.dart';
import '/screens/settings.dart';
import '/utils/allowed_tabs.dart';
import '/utils/main.dart';
import '/utils/pending_operation.dart';
import '/widgets/container_head.dart';
import '/widgets/decimal_field.dart';
import '/widgets/screen_card.dart';

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
    final l10n = AppLocalizations.of(context)!;

    String decimal = "";
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isOpen ? l10n.openingBalance : l10n.closingBalance),
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
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                ctx.pop();
              },
              child: Text(l10n.continueString),
            ),
          ],
        );
      },
    );
    return decimal;
  }

  late final l10n = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final shift = context.watch<ShiftProvider>().current;
    return Scaffold(
      appBar: AppBar(leading: SizedBox(), title: Text(l10n.home)),
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
                      l10n.welcome,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      softWrap: true,
                    ),
                    Text(
                      l10n.whatHappenInyourShop,
                      style: TextStyle(fontWeight: FontWeight.w500),
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
                                l10n.openShiftFirst,
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
                              child: Text(l10n.openShift),
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
                                    "${l10n.openedAt}: ${formatDateTimeSmart(shift.openedAt, showTime: false)}",
                                  ),
                                Text(
                                  "${l10n.openBalance}: ${shift.openingBalance}",
                                ),
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
                            child: Text(l10n.closeShift),
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
                      name: l10n.pos,
                      icon: Icons.point_of_sale,
                    ),
                  if (allowedTabs.contains("sales"))
                    ScreenCardWidget(
                      screenToGo: SalesScreen(),
                      name: l10n.sales,
                      icon: Icons.shopping_bag,
                    ),
                  if (allowedTabs.contains("accounting"))
                    ScreenCardWidget(
                      screenToGo: AccountingScreen(),
                      name: l10n.accounting,
                      icon: Icons.account_balance,
                    ),
                  if (allowedTabs.contains("purchase"))
                    ScreenCardWidget(
                      screenToGo: PurchaseScreen(),
                      name: l10n.purchases,
                      icon: Icons.shopping_cart,
                    ),
                  if (allowedTabs.contains("hr"))
                    ScreenCardWidget(
                      screenToGo: HR2Screen(),
                      name: l10n.hr,
                      icon: Icons.people,
                    ),
                  if (allowedTabs.contains("reports"))
                    ScreenCardWidget(
                      screenToGo: ReportsScreen(),
                      name: l10n.reports,
                      icon: Icons.leaderboard,
                    ),
                  if (allowedTabs.contains("inventory"))
                    ScreenCardWidget(
                      screenToGo: InventoryScreen(),
                      name: l10n.inventory,
                      icon: Icons.inventory,
                    ),
                  ScreenCardWidget(
                    screenToGo: SettingsScreen(),
                    name: l10n.settings,
                    icon: Icons.settings,
                  ),
                  // ScreenCardWidget(
                  //   screenToGo: AboutScreen(),
                  //   name: l10n.about,
                  //   icon: Icons.info,
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
