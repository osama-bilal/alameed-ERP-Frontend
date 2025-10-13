import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<PaymentMethod> methods = [];
  late final MainController<PaymentMethod> controller;
  @override
  void initState() {
    controller = MainController<PaymentMethod>(
      context: context,
    );
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
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PermissionGuard(
                requiredPermissions: ['add_paymentmethod'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_paymentmethod'],
                child: MySearchAnchor<PaymentMethod>(searchIn: methods),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_paymentmethod'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<PaymentMethod>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<PaymentMethod>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<PaymentMethod>) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<PaymentMethod>) {
                methods.clear();
                methods.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PaymentMethod>(
                  methods,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: PaymentMethod.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
