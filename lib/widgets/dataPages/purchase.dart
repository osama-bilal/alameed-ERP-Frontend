import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
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
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'purchaseitem'));
    controller = MainController<PurchaseItem>(context: context);
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
              Text("Purchased Items"),
              if (permissions['view']!) MySearchAnchor(searchIn: items),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_purchaseitem'],
          // fallback: Center(
          //   child: Text("You haven't requierd permission to view this table"),
          // ),
          child: BlocBuilder<GeneralBloc<PurchaseItem>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<PurchaseItem>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<PurchaseItem>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<PurchaseItem>) {
                if (state.operation == OperationType.add) {
                  items.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = items.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    items[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<PurchaseItem>) {
                items.clear();
                items.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PurchaseItem>(items, (o) => o.toMap()),
                columnsName: PurchaseItem.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
