import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Supplier> suppliers = [];
  late final MainController<Supplier> controller;
  @override
  void initState() {
    controller = MainController<Supplier>(
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
                requiredPermissions: ['add_supplier'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_supplier'],
                child: MySearchAnchor<Supplier>(searchIn: suppliers),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_supplier'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<Supplier>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Supplier>) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Supplier>) {
                return Center(child: Text('Error: ${state.error}'));
              } else if (state is ItemsLoadSuccess<Supplier>) {
                suppliers.clear();
                suppliers.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Supplier>(
                  suppliers,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: Supplier.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
