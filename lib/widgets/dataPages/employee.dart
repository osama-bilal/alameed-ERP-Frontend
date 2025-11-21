import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/employee.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
                  : Text("Employees"),
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
                if (state.operation == OperationType.add) {
                  employees.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = employees.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    employees[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
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
                      ? (o) {
                          employees.remove(o);
                          controller.deleteItem(o.id!);
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
