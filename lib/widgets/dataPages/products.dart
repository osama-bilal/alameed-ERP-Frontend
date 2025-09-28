import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/product.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

///select p.id, v.id, p.name, t.name, o.name, v.cost, v.price, v.barcode, v.quantity, b.name, c.name
///from ProductVariants v, Product p, optionsType t, optionsValue o, brand b, category c
///join where v.product == p.id and v.option_values.contain(o.id) and o.type == t.id, and p.category == c.id and p.brand == b.id
///
class ProductsPage extends StatelessWidget {
  ProductsPage({super.key});
  final List<Product> products = List.generate(
    50,
    (i) => Product(
      id: i,
      name: "Product $i",
      description: "Description $i",
      isActive: i % 2 == 0,
      brandId: i % 3,
      categoryId: i % 4,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<Product>()
        ..add(
          LoadItems(
            GeneralService<Product>(
              endpoint: "/products/products/",
              fromMap: Product.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: BlocBuilder<GeneralBloc<Product>, GeneralState>(
        builder: (context, state) {
          if (state is GeneralLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ItemLoadFailure) {
            return Center(child: Text(state.error));
          } else if (state is ItemsLoadSuccess<Product>) {
            products.clear();
            products.addAll(state.items);
          }
          return Column(
            children: [
              MyContainer(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CreateNewButton(onPressed: () {}),
                    SearchAnchor(
                      viewBackgroundColor: Colors.white,
                      viewPadding: EdgeInsets.symmetric(horizontal: 30),
                      shrinkWrap: true,
                      builder:
                          (BuildContext context, SearchController controller) {
                            return IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                // عند النقر على الأيقونة، يتم فتح حقل البحث
                                controller.openView();
                              },
                            );
                          },
                      // الدالة المسؤولة عن بناء قائمة الاقتراحات
                      suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
                            // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                            // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                            return products
                                .where((item) {
                                  return item.toString().toLowerCase().contains(
                                    controller.text.toLowerCase(),
                                  );
                                })
                                .map((item) {
                                  // عرض كل اقتراح كعنصر في القائمة
                                  return ListTile(
                                    title: Text(item.toString()),
                                    onTap: () {
                                      // عند النقر على اقتراح، يتم تحديث حقل البحث
                                      controller.closeView(item.toString());
                                    },
                                  );
                                })
                                .toList();
                          },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              MyPaginatedDataTable(
                datasource: MyDataSource<Product>(
                  products,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: Product.columnsName,
              ),
            ],
          );
        },
      ),
    );
  }
}
