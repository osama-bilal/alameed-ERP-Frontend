import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/salarypayment.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<SalaryPayment> payments = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<SalaryPayment>>(context).add(
        LoadItems(
          GeneralService<SalaryPayment>(
            endpoint: "/employees/salary-payments/",
            fromMap: SalaryPayment.fromMap,
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
                requiredPermissions: ['add_salarypayment'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_salarypayment'],
                child: MySearchAnchor<SalaryPayment>(searchIn: payments),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_salarypayment'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<SalaryPayment>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<SalaryPayment>) {
                payments.clear();
                payments.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<SalaryPayment>(
                  payments,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: SalaryPayment.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
