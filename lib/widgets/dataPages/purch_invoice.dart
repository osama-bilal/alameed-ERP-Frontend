import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class PurchaseInvoicePage extends StatefulWidget {
  const PurchaseInvoicePage({super.key});

  @override
  State<PurchaseInvoicePage> createState() => _PurchaseInvoicePageState();
}

class _PurchaseInvoicePageState extends State<PurchaseInvoicePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<PurchaseInvoice> invoices = [];
  late final MainController<PurchaseInvoice> controller;
  @override
  void initState() {
    controller = MainController<PurchaseInvoice>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final permissions = tablePermissions(context, 'purchaseinvoice');
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        // showEditDebtDialog(context, Debt()); // Old way
                      },
                    )
                  : Text("Purchase"),
              if (permissions['view']!) MySearchAnchor(searchIn: invoices),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_purchaseinvoice'],
          // fallback: Center(
          //   child: Text("You haven't requierd permission to view this table"),
          // ),
          child: BlocBuilder<GeneralBloc<PurchaseInvoice>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<PurchaseInvoice>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<PurchaseInvoice>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<PurchaseInvoice>) {
                if (state.operation == OperationType.add) {
                  invoices.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = invoices.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    invoices[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } else if (state is ItemsLoadSuccess<PurchaseInvoice>) {
                invoices.clear();
                invoices.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PurchaseInvoice>(
                  invoices,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          // showEditAttendanceDialog(context, o);
                          // TODO: Here handle edit action
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id!);
                          invoices.remove(o);
                        }
                      : null,
                ),
                columnsName: PurchaseInvoice.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
