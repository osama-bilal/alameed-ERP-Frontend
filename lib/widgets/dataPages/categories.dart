import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/category.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/category.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<ProductCategory> categories = [];
  List<ProductCategory> filteredCategories = [];
  late final MainController<ProductCategory> controller;
  final Map<String, bool> permissions = {};

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'category'));
    controller = MainController<ProductCategory>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredCategories = categories;
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
                        showEditCategoryDialog(
                          context,
                          ProductCategory(name: ""),
                        );
                      },
                    )
                  : Text(l10n.categories),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: categories,
                  onSubmitted: (res) =>
                      setState(() => filteredCategories = res),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_category'],
          child:
              BlocBuilder<
                GeneralBloc<ProductCategory>,
                GeneralState<ProductCategory>
              >(
                builder: (context, state) {
                  if (state is GeneralLoadInProgress<ProductCategory>) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ItemLoadFailure<ProductCategory>) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    });
                  } else if (state is ItemOperationSuccess<ProductCategory>) {
                    controller.fetchAll();
                  } else if (state is ItemsLoadSuccess<ProductCategory>) {
                    categories.clear();
                    categories.addAll(state.items);
                  }
                  if (filteredCategories.isEmpty) {
                    filteredCategories = categories;
                  }
                  return MyPaginatedDataTable(
                    datasource: MyDataSource<ProductCategory>(
                      filteredCategories,
                      (o) => o.toMap(),
                      editObject: permissions['change']!
                          ? (o) => showEditCategoryDialog(context, o)
                          : null,
                      deleteObject: permissions['delete']!
                          ? (o) => controller.deleteItem(o.id!)
                          : null,
                    ),
                    columnsName: ProductCategory.columnsName,
                  );
                },
              ),
        ),
      ],
    );
  }
}
