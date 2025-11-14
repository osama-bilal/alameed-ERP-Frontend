import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/payment_method.dart';
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
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'paymentmethod'));
    controller = MainController<PaymentMethod>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        showEditPaymentMethodDialog(
                          context,
                          PaymentMethod(methodName: ''),
                        );
                      },
                    )
                  : Text("Pay Methods"),
              if (permissions['view']!) MySearchAnchor(searchIn: methods),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_paymentmethod'],
          child: BlocBuilder<GeneralBloc<PaymentMethod>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<PaymentMethod>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<PaymentMethod>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<PaymentMethod>) {
                if (state.operation == OperationType.add) {
                  methods.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = methods.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    methods[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('deleted successfully')),
                    );
                  });
                }
              } else if (state is ItemsLoadSuccess<PaymentMethod>) {
                methods.clear();
                methods.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PaymentMethod>(
                  methods,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditPaymentMethodDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          methods.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
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
