import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/payment_method.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/payment_method.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

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
  List<PaymentMethod> filteredMethods = [];
  late final MainController<PaymentMethod> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'paymentmethod'));
    controller = MainController<PaymentMethod>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredMethods = methods;
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
                        showEditPaymentMethodDialog(
                          context,
                          PaymentMethod(methodName: ''),
                        );
                      },
                    )
                  : Text(l10n.paymentMethod),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: methods,
                  onSubmitted: (res) => setState(() => filteredMethods = res),
                ),
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
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<PaymentMethod>) {
                methods.clear();
                methods.addAll(state.items);
              }
              if (filteredMethods.isEmpty) {
                filteredMethods = methods;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<PaymentMethod>(
                  filteredMethods,
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
