import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/brand.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/brand.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
  late final MainController<Brand> controller;
  final Map<String, bool> permissions = {};

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'brand'));
    controller = MainController<Brand>(context: context);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        showEditBrandDialog(context, Brand(name: ""));
                      },
                    )
                  : const Text("Brands"),
              if (permissions['view']!) MySearchAnchor(searchIn: brands),
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
                if (state.operation == OperationType.add) {
                  brands.add(state.item!);
                } else if (state.operation == OperationType.update) {
                  final index = brands.indexWhere(
                    (b) => b.id == state.item!.id,
                  );
                  if (index != -1) {
                    brands[index] = state.item!;
                  }
                }
              } else if (state is ItemsLoadSuccess<Brand>) {
                brands.clear();
                brands.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Brand>(
                  brands,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) => showEditBrandDialog(context, o)
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) => controller.deleteItem(o.id!)
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
