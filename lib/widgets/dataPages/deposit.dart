import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/deposit.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class DepositsPage extends StatefulWidget {
  const DepositsPage({super.key});

  @override
  State<DepositsPage> createState() => _DepositsPageState();
}

class _DepositsPageState extends State<DepositsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Deposit> deposits = [];
  List<Deposit> filteredDeposits = [];
  late final MainController<Deposit> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'deposit'));
    controller = MainController<Deposit>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredDeposits = deposits;
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
                            builder: (context) => DepositEditPage(
                              deposit: Deposit(shiftId: -1, amount: '0.0'),
                            ),
                          ),
                        );
                      },
                    )
                  : Text("Deposits"),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: deposits,
                  onSubmitted: (res) => setState(() => filteredDeposits = res),
                  itemToString: (item) => item.toView(context).values.join(' '),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_deposit'],
          child: BlocBuilder<GeneralBloc<Deposit>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Deposit>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Deposit>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Deposit>) {
                if (state.operation == OperationType.add) {
                  deposits.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = deposits.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    deposits[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<Deposit>) {
                deposits.clear();
                deposits.addAll(state.items);
              }
              if (filteredDeposits.isEmpty) {
                filteredDeposits = deposits;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Deposit>(
                  filteredDeposits,
                  (o) => o.toView(context),
                  editObject: permissions['change']!
                      ? (o) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DepositEditPage(deposit: o),
                            ),
                          );
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          deposits.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
                ),
                columnsName: Deposit.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
