import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/invoices/sale.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

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
  List<ReturnSale> filteredReturns = [];

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'returnsale'));
    controller = MainController<ReturnSale>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = returns;
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
              Text(l10n.returns),
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
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<ReturnSale>) {
                returns.clear();
                returns.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = returns;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<ReturnSale>(
                  filteredReturns,
                  (o) => o.toMap(),
                ),
                columnsName: ReturnSale.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
