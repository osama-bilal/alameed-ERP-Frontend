import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  final List<Employee> employees = List.generate(
    5,
    (i) => Employee(
      firstName: "first $i",
      lastName: "Last $i",
      birthDate: DateTime.now().add(-Duration(days: 3650)),
      email: "ema${i}l@mail.com",
      position: "$i",
      salary: "1500",
      hireDate: DateTime.now(),
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<Employee>>(context).add(
        LoadItems(
          GeneralService<Employee>(
            endpoint: "/employees/employees/",
            fromMap: Employee.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PermissionGuard(
                requiredPermissions: ['add_employee'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_employee'],
                child: MySearchAnchor(searchIn: employees),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_employee'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<Employee>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text('Error: ${state.error}'));
              } else if (state is ItemsLoadSuccess<Employee>) {
                employees.clear();
                employees.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Employee>(
                  employees,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
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
