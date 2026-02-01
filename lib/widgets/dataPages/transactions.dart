import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/transections.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

class TransectionsPage extends StatefulWidget {
  const TransectionsPage({super.key});

  @override
  State<TransectionsPage> createState() => _TransectionsPageState();
}

class _TransectionsPageState extends State<TransectionsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<AccountTransaction> transections = [];
  late final MainController<AccountTransaction> controller;
  final Map<String, bool> permissions = {};
  List<AccountTransaction> filteredReturns = [];

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'accounttransaction'));
    controller = MainController<AccountTransaction>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = transections;
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
              Text(l10n.transactions),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: transections,
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                  itemToString: (item) => item.toView(context).values.join(' '),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_accounttransaction'],
          child: BlocBuilder<GeneralBloc<AccountTransaction>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<AccountTransaction>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<AccountTransaction>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemsLoadSuccess<AccountTransaction>) {
                transections.clear();
                transections.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = transections;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<AccountTransaction>(
                  filteredReturns,
                  (o) => o.toView(context),
                ),
                columnsName: AccountTransaction.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
