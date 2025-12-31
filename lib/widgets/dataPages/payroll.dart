import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/salarypayment.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/payroll.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<SalaryPayment> payments = [];
  List<SalaryPayment> filteredPayments = [];
  late final MainController<SalaryPayment> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'salarypayment'));
    controller = MainController<SalaryPayment>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredPayments = payments;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
        final l10n = AppLocalizations.of(context)!;

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
                            builder: (context) => PayrollEditPage(),
                          ),
                        );
                      },
                    )
                  : Text(l10n.payrolls),
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
          requiredPermissions: ['view_salarypayment'],
          child: BlocBuilder<GeneralBloc<SalaryPayment>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<SalaryPayment>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<SalaryPayment>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<SalaryPayment>) {
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
                    SnackBar(content: Text(l10n.deletedSuccessfully)),
                  );
                }
              } else if (state is ItemsLoadSuccess<SalaryPayment>) {
                payments.clear();
                payments.addAll(state.items);
              }
              if (filteredPayments.isEmpty) {
                filteredPayments = payments;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<SalaryPayment>(
                  filteredPayments,
                  (o) => o.toView(context),
                  editObject: permissions['change']!
                      ? (o) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PayrollEditPage(payroll: o),
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
                columnsName: SalaryPayment.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
