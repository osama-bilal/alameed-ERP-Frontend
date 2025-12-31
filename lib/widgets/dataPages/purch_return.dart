import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class ReturnPurchasePage extends StatefulWidget {
  const ReturnPurchasePage({super.key});

  @override
  State<ReturnPurchasePage> createState() => _ReturnPurchasePageState();
}

class _ReturnPurchasePageState extends State<ReturnPurchasePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<ReturnPurchase> returns = [];
  List<ReturnPurchase> filteredReturns = [];
  late final MainController<ReturnPurchase> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'returnpurchase'));
    controller = MainController<ReturnPurchase>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = returns;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    super.build(context);
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(onPressed: () {})
                  : Text("${l10n.returnString} ${l10n.purchases}"),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: returns,
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_returnpurchase'],
          child: BlocBuilder<GeneralBloc<ReturnPurchase>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<ReturnPurchase>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<ReturnPurchase>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<ReturnPurchase>) {
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
                    SnackBar(content: Text(l10n.deletedSuccessfully)),
                  );
                }
              } else if (state is ItemsLoadSuccess<ReturnPurchase>) {
                returns.clear();
                returns.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = returns;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<ReturnPurchase>(
                  filteredReturns,
                  (o) => o.toMap(),
                ),
                columnsName: ReturnPurchase.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
