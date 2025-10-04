import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/services/general_services.dart';
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

class _ReturnPurchasePageState extends State<ReturnPurchasePage> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  final List<ReturnPurchase> returns = List.generate(
    5,
    (i) => ReturnPurchase(
      purchaseItemId: i,
      quantity: i + 1,
      returnType: 'full',
      createdById: i,
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<ReturnPurchase>>(context).add(
        LoadItems(
          GeneralService<ReturnPurchase>(
            endpoint: "/invoices/return-purchases/",
            fromMap: ReturnPurchase.fromMap,
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
                requiredPermissions: ['add_returnpurchase'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_returnpurchase'],
                child: MySearchAnchor<ReturnPurchase>(searchIn: returns),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_returnpurchase'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<ReturnPurchase>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<ReturnPurchase>) {
                returns.clear();
                returns.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<ReturnPurchase>(
                  returns,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
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
