import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/product.dart';
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
  @override
  void initState() {
    controller = MainController<Product>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
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
              PermissionGuard(
                requiredPermissions: ['add_product'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_product'],
                child: MySearchAnchor(searchIn: products),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_product'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<Product>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<Product>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<Product>) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<Product>) {
                products.clear();
                products.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<Product>(
                  products,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
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
