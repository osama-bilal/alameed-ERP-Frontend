import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SalesReturnPage extends StatefulWidget {
  const SalesReturnPage({super.key});

  @override
  State<SalesReturnPage> createState() => _SalesReturnPageState();
}

class _SalesReturnPageState extends State<SalesReturnPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<ReturnSale> returns = [];
  late final MainController<ReturnSale> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'returnsale'));
    controller = MainController<ReturnSale>(context: context);
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
              Text("Sales Returned"),
              if (permissions['view']!) MySearchAnchor(searchIn: returns),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_returnsale'],
          child: BlocBuilder<GeneralBloc<ReturnSale>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<ReturnSale>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<ReturnSale>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<ReturnSale>) {
                if (state.operation == OperationType.add) {
                  returns.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = returns.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    returns[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<ReturnSale>) {
                returns.clear();
                returns.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<ReturnSale>(returns, (o) => o.toMap()),
                columnsName: ReturnSale.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
