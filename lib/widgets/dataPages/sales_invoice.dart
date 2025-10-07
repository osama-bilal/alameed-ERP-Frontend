import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/sales/invoice.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SaleInvoicePage extends StatefulWidget {
  const SaleInvoicePage({super.key});

  @override
  State<SaleInvoicePage> createState() => _SaleInvoicePageState();
}

class _SaleInvoicePageState extends State<SaleInvoicePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<SaleInvoice> invoices = [];
  late final SaleInvoiceController controller;
  @override
  void initState() {
    controller = SaleInvoiceController(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAll();
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
                requiredPermissions: ['add_saleinvoice'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_saleinvoice'],
                child: MySearchAnchor<SaleInvoice>(searchIn: invoices),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_saleinvoice'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<SaleInvoice>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(
                  child: Text('Failed to load invoices: ${state.error}'),
                );
              } else if (state is ItemsLoadSuccess<SaleInvoice>) {
                invoices.clear();
                invoices.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<SaleInvoice>(
                  invoices,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: SaleInvoice.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
