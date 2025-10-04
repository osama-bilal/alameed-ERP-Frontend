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

class PurchaseInvoicePage extends StatefulWidget {
  const PurchaseInvoicePage({super.key});

  @override
  State<PurchaseInvoicePage> createState() => _PurchaseInvoicePageState();
}

class _PurchaseInvoicePageState extends State<PurchaseInvoicePage> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  final List<PurchaseInvoice> invoices = List.generate(
    5,
    (i) => PurchaseInvoice(
      userId: i,
      status: [
        "draft",
        "final",
        "paid",
        "unpaid",
        "partially_paid",
        "cancelled",
      ][i % 6],
      refundStatus: 'not_refunded',
      subtotal: "100.0",
      tax: "10.0",
      discount: "5.0",
      total: "105.0",
      paid: "100",
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<PurchaseInvoice>>(context).add(
        LoadItems(
          GeneralService<PurchaseInvoice>(
            endpoint: "/invoices/purchase/",
            fromMap: PurchaseInvoice.fromMap,
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
                requiredPermissions: ['add_purchaseinvoice'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_purchaseinvoice'],
                child: MySearchAnchor<PurchaseInvoice>(searchIn: invoices),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_purchaseinvoice'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<PurchaseInvoice>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<PurchaseInvoice>) {
                invoices.clear();
                invoices.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PurchaseInvoice>(
                  invoices,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
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
