import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/purchases/invoice.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/screens/purchase%20pos/pos.dart';
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
  late final PurchaseInvoiceController controller;
  final Map<String, bool> permissions = {};
  List<PurchaseInvoice> filteredReturns = [];

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'purchaseinvoice'));
    controller = PurchaseInvoiceController(context: context);
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
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PosPurchScreen(),
                          ),
                        );
                      },
                    )
                  : Text(l10n.purchases),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: invoices,
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_purchaseinvoice'],
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
                    SnackBar(content: Text(l10n.deletedSuccessfully)),
                  );
                }
              } else if (state is ItemsLoadSuccess<PurchaseInvoice>) {
                invoices.clear();
                invoices.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = invoices;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PurchaseInvoice>(
                  filteredReturns,
                  (o) => o.toView(context),
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
                columnsName: PurchaseInvoice.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
