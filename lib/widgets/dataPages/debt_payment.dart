import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
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
  @override
  void initState() {
    controller = MainController<DebtPayment>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final permissions = tablePermissions(context, 'dabtpayment');
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PermissionGuard(
                requiredPermissions: ['add_debtpayment'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_debtpayment'],
                child: MySearchAnchor(searchIn: payments),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_debtpayment'],
          child: BlocBuilder<GeneralBloc<DebtPayment>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<DebtPayment>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<DebtPayment>) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<DebtPayment>) {
                payments.clear();
                payments.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<DebtPayment>(
                  payments,
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
