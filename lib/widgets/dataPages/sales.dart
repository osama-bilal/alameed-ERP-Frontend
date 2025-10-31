import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/sales/item.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SaleItemsPage extends StatefulWidget {
  const SaleItemsPage({super.key});

  @override
  State<SaleItemsPage> createState() => _SaleItemsPageState();
}

class _SaleItemsPageState extends State<SaleItemsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<SaleItem> sales = [];
  late final SaleItemsController controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'saleitem'));
    controller = SaleItemsController(context: context);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sales Items"),
              if (permissions['view']!) MySearchAnchor(searchIn: sales),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_saleitem'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<SaleItem>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<SaleItem>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<SaleItem>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemsLoadSuccess<SaleItem>) {
                sales.clear();
                sales.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<SaleItem>(sales, (o) => o.toMap()),
                columnsName: SaleItem.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
