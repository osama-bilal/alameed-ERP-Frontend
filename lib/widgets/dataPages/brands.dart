import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/brand.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/brand.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Brand> brands = [];
  List<Brand> filteredBrands = [];
  late final MainController<Brand> controller;
  final Map<String, bool> permissions = {};

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'brand'));
    controller = MainController<Brand>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredBrands = brands;
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
                        showEditBrandDialog(context, Brand(name: ""));
                      },
                    )
                  : Text(l10n.brands),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: brands,
                  onSubmitted: (res) => setState(() => filteredBrands = res),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_brand'],
          child: BlocBuilder<GeneralBloc<Brand>, GeneralState<Brand>>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Brand>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Brand>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemOperationSuccess<Brand>) {
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<Brand>) {
                brands.clear();
                brands.addAll(state.items);
              }
              if (filteredBrands.isEmpty) {
                filteredBrands = brands;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Brand>(
                  filteredBrands,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) => showEditBrandDialog(context, o)
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
                                    brands.remove(o);
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
                columnsName: Brand.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
