import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/hr/shift.dart';
import '/l10n/app_localizations.dart';
import '/models/shift.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

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
  List<Shift> filteredReturns = [];

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'shift'));
    controller = ShiftController(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = shifts;
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
              Text(l10n.shifts),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: shifts,
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                  itemToString: (item) => item.toView(context).values.join(' '),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_shift'],
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
                controller.fetchAll();
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = shifts;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Shift>(
                  filteredReturns,
                  (o) => o.toView(context),
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
