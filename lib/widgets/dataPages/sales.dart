import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/sales/item.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
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
  @override
  void initState() {
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
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PermissionGuard(
                requiredPermissions: ['add_saleitem'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_saleitem'],
                child: MySearchAnchor<SaleItem>(searchIn: sales),
              ),
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
              if (state is GeneralLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<SaleItem>) {
                sales.clear();
                sales.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<SaleItem>(
                  sales,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: SaleItem.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
