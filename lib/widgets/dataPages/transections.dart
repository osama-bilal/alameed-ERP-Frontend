import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/transections.dart';
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

class _TransectionsPageState extends State<TransectionsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<AccountTransaction> transections = [];
  late final MainController<AccountTransaction> controller;
  @override
  void initState() {
    controller = MainController<AccountTransaction>(context: context);
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
              if (state is GeneralLoadInProgress<AccountTransaction>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<AccountTransaction>) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<AccountTransaction>) {
                transections.clear();
                transections.addAll(state.items);
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
    );
  }
}
