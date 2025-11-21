import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/debt.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/debt_payment.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Debt> debts = [];
  List<Debt> filteredDebts = [];
  late final MainController<Debt> controller;
  final Map<String, bool> permissions = {};

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'debt'));
    controller = MainController<Debt>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredDebts = debts;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DebtEditPage(debt: Debt()),
                          ),
                        );
                      },
                    )
                  : Text("Debts"),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: debts,
                  itemToString: (debt) => debt.toView(context).values.join(' '),
                  onSubmitted: (res) {
                    setState(() => filteredDebts = res);
                  },
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_debt'],
          child: BlocBuilder<GeneralBloc<Debt>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Debt>) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Debt>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Debt>) {
                if (state.operation == OperationType.add) {
                  debts.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = debts.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    debts[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('deleted successfully')),
                    );
                  });
                }
              } else if (state is ItemsLoadSuccess<Debt>) {
                debts.clear();
                debts.addAll(state.items);
              }
              if (filteredDebts.isEmpty) {
                filteredDebts = debts;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Debt>(
                  filteredDebts,
                  (o) => o.toView(context),
                  // ... inside _DebtPageState build method, in MyPaginatedDataTable
                  editObject: permissions['change']!
                      ? (o) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DebtEditPage(debt: o),
                            ),
                          );
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          debts.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
                  extraActions: {
                    Icons.attach_money_sharp: (o) => showEditDebtPaymentDialog(
                      context,
                      DebtPayment(debtId: o.id!),
                    ),
                  },
                ),
                columnsName: Debt.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
