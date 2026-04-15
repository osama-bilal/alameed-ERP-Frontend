import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/employee.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/employee.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  late final MainController<Employee> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'employee'));
    controller = MainController<Employee>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredEmployees = employees;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        showEditEmployeeDialog(
                          context,
                          Employee(
                            firstName: "",
                            lastName: "",
                            birthDate: DateTime(2000),
                            email: "",
                            position: "",
                            salary: "0.0",
                            hireDate: DateTime.now(),
                          ),
                        );
                      },
                    )
                  : Text(l10n.employees),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: employees,
                  onSubmitted: (res) => setState(() => filteredEmployees = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_employee'],
          child: BlocBuilder<GeneralBloc<Employee>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Employee>) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Employee>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Employee>) {
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<Employee>) {
                employees.clear();
                employees.addAll(state.items);
              }
              if (filteredEmployees.isEmpty) {
                filteredEmployees = employees;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Employee>(
                  filteredEmployees,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditEmployeeDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ?  (o) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.delete),
                              content: Text(l10n.areYouSure),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text(l10n.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.deleteItem(o.id!);
                                    employees.remove(o);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  excludeFields: [
                    'created_at',
                    'updated_at',
                    'deleted_at',
                    'updated_by',
                    'created_by',
                    'useraccount',
                  ],
                ),
                columnsName: Employee.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
