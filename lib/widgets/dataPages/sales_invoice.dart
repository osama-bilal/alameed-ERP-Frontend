import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/sales/invoice.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/screens/details/sale_invoice_details_page.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
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
  final Map<String, bool> permissions = {};
  List<SaleInvoice> filteredReturns = [];

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'saleinvoice'));
    controller = SaleInvoiceController(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = invoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
        final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.sales),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: invoices,
                  itemToString: (item) => item.toView(context).values.join(' '),
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_saleinvoice'],
          child: BlocBuilder<GeneralBloc<SaleInvoice>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<SaleInvoice>) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<SaleInvoice>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<SaleInvoice>) {
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
                    SnackBar(content: Text(l10n.deletedSuccessfully)),
                  );
                }
              } else if (state is ItemsLoadSuccess<SaleInvoice>) {
                invoices.clear();
                invoices.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = invoices;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<SaleInvoice>(
                  filteredReturns,
                  (o) => o.toView(context),
                  viewObject: (o) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SaleInvoiceDetailsPage(invoice: o),
                    ),
                  ),
                  extraActions: {
                    Icons.done_all_sharp: (o) {
                      if (o.status == 'draft') {
                        controller.finalize(o.id!);
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("the invoice must be Draft"),
                            ),
                          );
                        });
                      }
                    },
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
