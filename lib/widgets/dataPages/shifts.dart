import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/shift.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
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
  late final MainController<Shift> controller;
  @override
  void initState() {
    controller = MainController<Shift>(
      context: context,
      service: AppService.shiftService,
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
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
                requiredPermissions: ['add_shift'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_shift'],
                child: MySearchAnchor<Shift>(searchIn: shifts),
              ),
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
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<Shift>) {
                shifts.clear();
                shifts.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Shift>(
                  shifts,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
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
