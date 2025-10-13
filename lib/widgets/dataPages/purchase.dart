import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<PurchaseItem> items = [];
  late final MainController<PurchaseItem> controller;
  @override
  void initState() {
    controller = MainController<PurchaseItem>(
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
                requiredPermissions: ['add_purchaseitem'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_purchaseitem'],
                child: MySearchAnchor<PurchaseItem>(searchIn: items),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_purchaseitem'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<PurchaseItem>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<PurchaseItem>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<PurchaseItem>) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<PurchaseItem>) {
                items.clear();
                items.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PurchaseItem>(
                  items,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: PurchaseItem.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
