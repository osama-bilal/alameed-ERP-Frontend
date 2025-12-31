import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/customers.dart';
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
  List<Customer> filteredCustomers = [];
  late final MainController<Customer> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'customer'));
    controller = MainController<Customer>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredCustomers = customers;
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
                        showEditCustomerDialog(
                          context,
                          Customer(name: "", phone: ""),
                        );
                      },
                    )
                  : Text(l10n.customers),
              if (permissions['view']!)
                MySearchAnchor<Customer>(
                  searchIn: customers,
                  onSubmitted: (res) => setState(() => filteredCustomers = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_customer'],
          child: BlocBuilder<GeneralBloc<Customer>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Customer>) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Customer>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Customer>) {
                if (state.operation == OperationType.add) {
                  customers.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = customers.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    customers[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.deletedSuccessfully)),
                    );
                  });
                }
              } else if (state is ItemsLoadSuccess<Customer>) {
                customers.clear();
                customers.addAll(state.items);
              }
              if (filteredCustomers.isEmpty) {
                filteredCustomers = customers;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Customer>(
                  filteredCustomers,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditCustomerDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          customers.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
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
