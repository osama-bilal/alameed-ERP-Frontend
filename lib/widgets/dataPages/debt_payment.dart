import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/debt.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/edits%20pages/debt_payment.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

class DebtPayPage extends StatefulWidget {
  const DebtPayPage({super.key});

  @override
  State<DebtPayPage> createState() => _DebtPayPageState();
}

class _DebtPayPageState extends State<DebtPayPage>
    with AutomaticKeepAliveClientMixin {
  final List<DebtPayment> payments = [];
  List<DebtPayment> filteredPayments = [];
  late final MainController<DebtPayment> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'debtpayment'));
    controller = MainController<DebtPayment>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredPayments = payments;
    });
  }

  @override
  bool get wantKeepAlive => true;
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
              Text(l10n.debtsPayments),
              if (permissions['view']!)
                MySearchAnchor<DebtPayment>(
                  searchIn: payments,
                  itemToString: (item) => item.toView(context).values.join(' '),
                  onSubmitted: (res) => setState(() => filteredPayments = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_debtpayment'],
          child:
              BlocBuilder<GeneralBloc<DebtPayment>, GeneralState<DebtPayment>>(
                builder: (context, state) {
                  if (state is GeneralLoadInProgress<DebtPayment>) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ItemLoadFailure<DebtPayment>) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    });
                  } else if (state is ItemOperationSuccess<DebtPayment>) {
                    controller.fetchAll();
                  } else if (state is ItemsLoadSuccess<DebtPayment>) {
                    payments.clear();
                    payments.addAll(state.items);
                  }
                  if (filteredPayments.isEmpty) {
                    filteredPayments = payments;
                  }
                  return MyPaginatedDataTable(
                    datasource: MyDataSource<DebtPayment>(
                      filteredPayments,
                      excludeFields: [],
                      (o) => o.toView(context),
                      editObject: permissions['change']!
                          ? (o) {
                              showEditDebtPaymentDialog(context, o);
                            }
                          : null,
                      deleteObject: permissions['delete']!
                          ? (o) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.delete),
                              content: Text(l10n.areYouSure),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text(l10n.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.deleteItem(o.id!);
                                    payments.remove(o);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                            }
                          : null,
                    ),
                    columnsName: DebtPayment.columnsName,
                  );
                },
              ),
        ),
      ],
    );
  }
}
