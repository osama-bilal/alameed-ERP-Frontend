import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with AutomaticKeepAliveClientMixin {
  final List<Customer> customers = [];
  late final MainController<Customer> controller;
  @override
  void initState() {
    controller = MainController<Customer>(
      context: context,
      service: AppService.customerService,
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
                requiredPermissions: ['add_customer'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_customer'],
                child: MySearchAnchor(searchIn: customers),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_customer'],
          child: BlocBuilder<GeneralBloc<Customer>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text('Error: ${state.error}'));
              } else if (state is ItemsLoadSuccess<Customer>) {
                customers.clear();
                customers.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Customer>(
                  customers,
                  (o) => o.toMap(),
                  editObject: (Customer o) {
                    //TODO: Handle edit action
                  },
                ),
                columnsName: Customer.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
