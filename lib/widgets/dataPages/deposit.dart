import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class DepositsPage extends StatefulWidget {
  const DepositsPage({super.key});

  @override
  State<DepositsPage> createState() => _DepositsPageState();
}

class _DepositsPageState extends State<DepositsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Deposit> deposits = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<Deposit>>(context).add(
        LoadItems(
          GeneralService<Deposit>(
            endpoint: "/expenses/deposits/",
            fromMap: Deposit.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
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
                requiredPermissions: ['add_deposit'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_deposit'],
                child: MySearchAnchor(searchIn: deposits),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_deposit'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<Deposit>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess) {
                deposits.clear();
                deposits.addAll(state.items as List<Deposit>);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Deposit>(
                  deposits,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: Deposit.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
