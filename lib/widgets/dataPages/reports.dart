import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/report.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/report.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/screens/details/report_details_page.dart';

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
  List<Report> filteredReports = [];
  late final ReportController controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'report'));
    controller = ReportController(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReports = reports;
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
                            builder: (context) => const ReportCreatePage(),
                          ),
                        );
                      },
                    )
                  : Text("Reports"),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: reports,
                  onSubmitted: (res) => setState(() => filteredReports = res),
                ),
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
              if (filteredReports.isEmpty) {
                filteredReports = reports;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Report>(
                  filteredReports,
                  (o) => o.toMap(),
                  viewObject: (o) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsPage(report: o),
                    ),
                  ),
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id);
                          reports.remove(o);
                        }
                      : null,
                  extraActions: {
                    Icons.calculate: (o) => controller.generate(o.id),
                  },
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
