import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/product.dart';
import 'package:ponit_of_sales/screens/product_edit_page.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
  late final MainController<Product> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'product'));
    controller = MainController<Product>(context: context);
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProductEditPage(),
                          ),
                        );
                      },
                    )
                  : Text("Products"),
              if (permissions['view']!) MySearchAnchor(searchIn: products),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_product'],
          child: BlocBuilder<GeneralBloc<Product>, GeneralState>(
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
                if (state.operation == OperationType.add) {
                  products.add(state.item!);
                } else if (state.operation == OperationType.update ||
                    state.operation == OperationType.partiallyUpdate) {
                  final index = products.indexWhere(
                    (user) => user.id == state.item!.id,
                  );
                  if (index != -1) {
                    products[index] = state.item!;
                  }
                } else if (state.operation == OperationType.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('deleted successfully')),
                  );
                }
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Product>(
                  products,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              // You might need to fetch variants for the product here
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
