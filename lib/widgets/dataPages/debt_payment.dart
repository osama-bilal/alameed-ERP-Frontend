import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/debt_payment.dart';
// import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class DebtPayPage extends StatefulWidget {
  const DebtPayPage({super.key});

  @override
  State<DebtPayPage> createState() => _DebtPayPageState();
}

class _DebtPayPageState extends State<DebtPayPage>
    with AutomaticKeepAliveClientMixin {
  final List<DebtPayment> payments = [];
  late final MainController<DebtPayment> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'debtpayment'));
    controller = MainController<DebtPayment>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAll();
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Debts Payments"),
              if (permissions['view']!) MySearchAnchor(searchIn: payments),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_debtpayment'],
          child:
              BlocBuilder<GeneralBloc<DebtPayment>, GeneralState<DebtPayment>>(
                builder: (context, state) {
                  if (state is GeneralLoadInProgress<DebtPayment>) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ItemLoadFailure<DebtPayment>) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    });
                  } else if (state is ItemOperationSuccess<DebtPayment>) {
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
                  } else if (state is ItemsLoadSuccess<DebtPayment>) {
                    payments.clear();
                    payments.addAll(state.items);
                  }
                  return MyPaginatedDataTable(
                    datasource: MyDataSource<DebtPayment>(
                      payments,
                      excludeFields: [],
                      (o) => o.toMap(),
                      editObject: permissions['change']!
                          ? (o) {
                              showEditDebtPaymentDialog(context, o);
                            }
                          : null,
                      deleteObject: permissions['delete']!
                          ? (o) {
                              payments.remove(o);
                              controller.deleteItem(o.id!);
                            }
                          : null,
                    ),
                    columnsName: DebtPayment.columnsName,
                  );
                },
              ),
        ),
      ],
    );
  }
}
