import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/expense.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Expense> payments = [];
  List<Expense> filteredPayments = [];
  late final MainController<Expense> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'expense'));
    controller = MainController<Expense>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredPayments = payments;
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
                            builder: (context) => ExpenseEditPage(
                              expense: Expense(shiftId: -1, amount: '0.0'),
                            ),
                          ),
                        );
                      },
                    )
                  : Text("Expenses"),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: payments,
                  itemToString: (item) => item.toView(context).values.join(' '),
                  onSubmitted: (res) => setState(() => filteredPayments = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_expense'],
          child: BlocBuilder<GeneralBloc<Expense>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Expense>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Expense>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Expense>) {
                if (state.operation == OperationType.add) {
                  payments.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = payments.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    payments[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<Expense>) {
                payments.clear();
                payments.addAll(state.items);
              }
              if (filteredPayments.isEmpty) {
                filteredPayments = payments;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Expense>(
                  filteredPayments,
                  (o) => o.toView(context),
                  editObject: permissions['change']!
                      ? (o) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ExpenseEditPage(expense: o),
                            ),
                          );
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          payments.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
                ),
                columnsName: Expense.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
