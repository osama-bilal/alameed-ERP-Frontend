import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/stockmovement.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/stock_adjustment.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class MovementsPage extends StatefulWidget {
  const MovementsPage({super.key});

  @override
  State<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends State<MovementsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<StockMovement> movements = [];
  late final MainController<StockMovement> controller;
  final Map<String, bool> permissions = {};
  List<StockMovement> filteredReturns = [];
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'stockmovement'));
    controller = MainController<StockMovement>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = movements;
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const StockAdjustmentPage(),
                          ),
                        );
                      },
                    )
                  : Text(l10n.stockMovements),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: movements,
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                  itemToString: (item) => item.toView(context).values.join(' '),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_stockmovement'],
          child: BlocBuilder<GeneralBloc<StockMovement>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<StockMovement>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<StockMovement>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<StockMovement>) {
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<StockMovement>) {
                movements.clear();
                movements.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = movements;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<StockMovement>(
                  filteredReturns,
                  (o) => o.toView(context),
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id!);
                          movements.remove(o);
                        }
                      : null,
                ),
                columnsName: StockMovement.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
