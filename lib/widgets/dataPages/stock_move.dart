import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/stockmovement.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
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
  @override
  void initState() {
    controller = MainController<StockMovement>(
      context: context,
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
                requiredPermissions: ['add_stockmovement'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_stockmovement'],
                child: MySearchAnchor<StockMovement>(searchIn: movements),
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
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<StockMovement>) {
                movements.clear();
                movements.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<StockMovement>(
                  movements,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
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
