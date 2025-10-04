import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage>  with AutomaticKeepAliveClientMixin{
  
  @override
  bool get wantKeepAlive => true;
  final List<Debt> debts = List.generate(
    5,
    (i) => Debt(
      partyType: ["Customer", "Supplier", "Employee"][i % 3],
      partyId: i,
      kind: ["product", "cash", "previous"][i % 3],
      amount: (1000.0 - i).toString(),
      paid: i.toString(),
      returned: "0.00",
      status: "unpaid",
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<Debt>>(context)
        .add(
          LoadItems(
            GeneralService<Debt>(
              endpoint: "/debts/debts/",
              fromMap: Debt.fromMap,
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
                requiredPermissions: ['add_debt'],
                fallback: Text("Debts Table"),
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_debt'],
                child: MySearchAnchor(searchIn: debts),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_debt'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<Debt>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(
                  child: Text('Failed to load debts: ${state.error}'),
                );
              } else if (state is ItemsLoadSuccess<Debt>) {
                debts.clear();
                debts.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Debt>(
                  debts,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: Debt.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
