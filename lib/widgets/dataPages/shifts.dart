import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/hr/shift.dart';
import 'package:ponit_of_sales/models/shift.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class ShiftsPage extends StatefulWidget {
  const ShiftsPage({super.key});

  @override
  State<ShiftsPage> createState() => _ShiftsPageState();
}

class _ShiftsPageState extends State<ShiftsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Shift> shifts = [];
  late final ShiftController controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'shift'));
    controller = ShiftController(context: context);
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
              Text("Shifts"),
              if (permissions['view']!) MySearchAnchor(searchIn: shifts),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_shift'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<Shift>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Shift>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Shift>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemsLoadSuccess<Shift>) {
                shifts.clear();
                shifts.addAll(state.items);
              } else if (state is ItemOperationSuccess<Shift>) {
                if (state.operation == OperationType.add) {
                  shifts.add(state.item!);
                } else if (state.operation == OperationType.update) {
                  final index = shifts.indexWhere(
                    (element) => element.id == state.item!.id,
                  );
                  if (index != -1) {
                    shifts[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Shift>(
                  shifts,
                  (o) => o.toMap(),
                  deleteObject: permissions['delete']!
                      ? (o) {
                          shifts.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
                  extraActions: {
                    Icons.lock_clock_outlined: (o) =>
                        controller.close(o.id!, "0.0"),
                  },
                ),
                columnsName: Shift.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
