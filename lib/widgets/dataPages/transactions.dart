import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/transections.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Accounts Transactions"),
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
