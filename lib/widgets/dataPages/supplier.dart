import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/supplier.dart';
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
    controller = MainController<Supplier>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final permissions = tablePermissions(context, 'supplier');
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        showEditSupplierDialog(
                          context,
                          Supplier(name: "", phone: "", address: ""),
                        );
                      },
                    )
                  : Text("Suppliers"),
              if (permissions['view']!) MySearchAnchor(searchIn: suppliers),
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Supplier>) {
                if (state.operation == OperationType.add) {
                  suppliers.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = suppliers.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    suppliers[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<Supplier>) {
                suppliers.clear();
                suppliers.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Supplier>(
                  suppliers,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditSupplierDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id!);
                          suppliers.remove(o);
                        }
                      : null,
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
