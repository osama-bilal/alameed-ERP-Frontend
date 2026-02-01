import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/product.dart';
import '/screens/product_edit_page.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

///select p.id, v.id, p.name, t.name, o.name, v.cost, v.price, v.barcode, v.quantity, b.name, c.name
///from ProductVariants v, Product p, optionsType t, optionsValue o, brand b, category c
///join where v.product == p.id and v.option_values.contain(o.id) and o.type == t.id, and p.category == c.id and p.brand == b.id
///
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<Product> products = [];
  List<Product> filteredProducts = [];
  late final MainController<Product> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'product'));
    controller = MainController<Product>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredProducts = products;
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProductEditPage(),
                          ),
                        );
                      },
                    )
                  : Text(l10n.products),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: products,
                  itemToString: (item) => item.toView(context).values.join(' '),
                  onSubmitted: (res) => setState(() => filteredProducts = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_product'],
          child: BlocBuilder<GeneralBloc<Product>, GeneralState<Product>>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Product>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Product>) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                });
              } else if (state is ItemsLoadSuccess<Product>) {
                products.clear();
                products.addAll(state.items);
              } else if (state is ItemOperationSuccess<Product>) {
                controller.fetchAll();
              }
              if (filteredProducts.isEmpty) {
                filteredProducts = products;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Product>(
                  filteredProducts,
                  (o) => o.toView(context),
                  editObject: permissions['change']!
                      ? (o) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductEditPage(product: o),
                            ),
                          );
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          controller.deleteItem(o.id!);
                          products.remove(o);
                        }
                      : null,
                ),
                columnsName: Product.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
