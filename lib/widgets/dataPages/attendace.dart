import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with AutomaticKeepAliveClientMixin {
  final List<Attendance> attendaces = [];
  late final MainController<Attendance> controller;
  @override
  void initState() {
    controller = MainController<Attendance>(
      context: context,
      service: AppService.attendanceService,
    );
    super.initState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final permissions = tablePermissions(context, 'attendance');
    return Column(
      children: [
        MyContainer(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (permissions['add']!)
                CreateNewButton(onPressed: () {})
              else
                Text("Attendance Table"),
              if (permissions['view']!)
                MySearchAnchor<Attendance>(searchIn: attendaces),
            ],
          ),
        ),
        SizedBox(height: 20),
        if (permissions['view']!)
          BlocBuilder<GeneralBloc<Attendance>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(
                  child: Text('Failed to load attendaces: ${state.error}'),
                );
              } else if (state is ItemsLoadSuccess<Attendance>) {
                attendaces.clear();
                attendaces.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Attendance>(
                  attendaces,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                  canDelete: permissions['delete']!,
                  canEdit: permissions['change']!,
                ),
                columnsName: Attendance.columnsName,
              );
            },
          )
        else
          Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
