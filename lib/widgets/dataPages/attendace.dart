import 'package:flutter/material.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/attendance.dart';
// import '/utils/pending_operation.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/attendance.dart';
import '/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/widgets/search_anchor.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with AutomaticKeepAliveClientMixin {
  final List<Attendance> attendaces = [];
  List<Attendance> filteredAttendances = [];
  late final MainController<Attendance> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'debt'));
    controller = MainController<Attendance>(context: context);
    super.initState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredAttendances = attendaces;
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
                        showCreateAttendanceDialog(context);
                      },
                    )
                  : Text(l10n.attendances),
              if (permissions['view']!)
                MySearchAnchor<Attendance>(
                  searchIn: attendaces,
                  itemToString: (item) => item.toView(context).values.join(' '),
                  onSubmitted: (res) =>
                      setState(() => filteredAttendances = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        if (permissions['view']!)
          BlocBuilder<GeneralBloc<Attendance>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Attendance>) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Attendance>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Attendance>) {
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<Attendance>) {
                attendaces.clear();
                attendaces.addAll(state.items);
              }
              if (filteredAttendances.isEmpty) {
                filteredAttendances = attendaces;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Attendance>(
                  filteredAttendances,
                  (o) => o.toView(context),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditAttendanceDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          attendaces.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
                ),
                columnsName: Attendance.columnsName,
              );
            },
          )
        else
          Center(child: Text(l10n.cantAccessPage)),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
