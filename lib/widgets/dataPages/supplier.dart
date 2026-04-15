import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/supplier.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/supplier.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

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
  final Map<String, bool> permissions = {};
  List<Supplier> filteredReturns = [];

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'supplier'));
    controller = MainController<Supplier>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredReturns = suppliers;
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
                        showEditSupplierDialog(
                          context,
                          Supplier(name: "", phone: "", address: ""),
                        );
                      },
                    )
                  : Text(l10n.supplier),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: suppliers,
                  onSubmitted: (res) => setState(() => filteredReturns = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_supplier'],
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
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<Supplier>) {
                suppliers.clear();
                suppliers.addAll(state.items);
              }
              if (filteredReturns.isEmpty) {
                filteredReturns = suppliers;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Supplier>(
                  filteredReturns,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditSupplierDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ?  (o) {
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
                                    suppliers.remove(o);
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
                columnsName: Supplier.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
