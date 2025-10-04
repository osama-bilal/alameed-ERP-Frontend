import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class DebtPayPage extends StatefulWidget {
  const DebtPayPage({super.key});

  @override
  State<DebtPayPage> createState() => _DebtPayPageState();
}

class _DebtPayPageState extends State<DebtPayPage>
    with AutomaticKeepAliveClientMixin {
  final List<DebtPayment> payments = List.generate(
    5,
    (i) => DebtPayment(
      debtId: i,
      amount: "${i * i + i}",
      createdAt: DateTime.now(),
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<DebtPayment>>(context).add(
        LoadItems(
          GeneralService<DebtPayment>(
            endpoint: "/debts/payments/",
            fromMap: DebtPayment.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
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
                requiredPermissions: ['add_debtpayment'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_debtpayment'],
                child: MySearchAnchor(searchIn: payments),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_debtpayment'],
          child: BlocBuilder<GeneralBloc<DebtPayment>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess) {
                payments.clear();
                payments.addAll(state.items as List<DebtPayment>);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<DebtPayment>(
                  payments,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: DebtPayment.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
