import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Report> reports = [];
  late final MainController<Report> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'report'));
    controller = MainController<Report>(context: context);
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
                  : Text("Reports"),
              if (permissions['view']!) MySearchAnchor(searchIn: reports),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_report'],
          child: BlocBuilder<GeneralBloc<Report>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Report>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Report>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Report>) {
                if (state.operation == OperationType.add) {
                  reports.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = reports.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    reports[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<Report>) {
                reports.clear();
                reports.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Report>(
                  reports,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          // showEditAttendanceDialog(context, o);
                          // TODO: Here handle edit action
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id);
                          reports.remove(o);
                        }
                      : null,
                ),
                columnsName: Report.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
