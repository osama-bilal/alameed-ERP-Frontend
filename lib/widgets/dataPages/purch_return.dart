import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class ReturnPurchasePage extends StatefulWidget {
  const ReturnPurchasePage({super.key});

  @override
  State<ReturnPurchasePage> createState() => _ReturnPurchasePageState();
}

class _ReturnPurchasePageState extends State<ReturnPurchasePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<ReturnPurchase> returns = [];
  late final MainController<ReturnPurchase> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'returnpurchase'));
    controller = MainController<ReturnPurchase>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAll();
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
                        // showEditDebtDialog(context, Debt()); // Old way
                      },
                    )
                  : Text("Purchase Return"),
              if (permissions['view']!) MySearchAnchor(searchIn: returns),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_returnpurchase'],
          // fallback: Center(
          //   child: Text("You haven't requierd permission to view this table"),
          // ),
          child: BlocBuilder<GeneralBloc<ReturnPurchase>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<ReturnPurchase>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<ReturnPurchase>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<ReturnPurchase>) {
                if (state.operation == OperationType.add) {
                  returns.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = returns.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    returns[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<ReturnPurchase>) {
                returns.clear();
                returns.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<ReturnPurchase>(
                  returns,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          // showEditAttendanceDialog(context, o);
                          // TODO: Here handle edit action
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id!);
                          returns.remove(o);
                        }
                      : null,
                ),
                columnsName: ReturnPurchase.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
