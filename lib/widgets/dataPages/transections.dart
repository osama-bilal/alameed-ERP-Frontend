import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/transections.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class TransectionsPage extends StatefulWidget {
  const TransectionsPage({super.key});

  @override
  State<TransectionsPage> createState() => _TransectionsPageState();
}

class _TransectionsPageState extends State<TransectionsPage> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  final List<AccountTransaction> transections = List.generate(
    10,
    (i) => AccountTransaction(
      id: i,
      contentType: i,
      objectId: i,
      amount: "${i * 100.0}",
      transactionType: 'type_${i % 2}',
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<AccountTransaction>>(context).add(
        LoadItems(
          GeneralService<AccountTransaction>(
            endpoint: "/expenses/accounts/",
            fromMap: AccountTransaction.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => GeneralBloc<AccountTransaction>()
        ..add(
          LoadItems(
            GeneralService<AccountTransaction>(
              endpoint: "/expenses/accounts/",
              fromMap: AccountTransaction.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: Column(
        children: [
          MyContainer(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PermissionGuard(
                  requiredPermissions: ['add_accounttransaction'],
                  child: CreateNewButton(onPressed: () {}),
                ),
                PermissionGuard(
                  requiredPermissions: ['view_accounttransaction'],
                  child: MySearchAnchor<AccountTransaction>(
                    searchIn: transections,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          PermissionGuard(
            requiredPermissions: ['view_accounttransaction'],
            fallback: Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
            child: BlocBuilder<GeneralBloc<AccountTransaction>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(child: Text(state.error));
                } else if (state is ItemsLoadSuccess) {
                  transections.clear();
                  transections.addAll(state.items as List<AccountTransaction>);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<AccountTransaction>(
                    transections,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                    },
                  ),
                  columnsName: AccountTransaction.columnsName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
