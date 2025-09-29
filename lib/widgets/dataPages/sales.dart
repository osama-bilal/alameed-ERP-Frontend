import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class SaleItemsPage extends StatelessWidget {
  SaleItemsPage({super.key});
  final List<SaleItem> sales = List.generate(
    20,
    (i) => SaleItem(
      variantId: i,
      quantity: i + 1,
      unitPrice: (i * (i + 1)).toString(),
      invoiceId: i,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<SaleItem>()
        ..add(
          LoadItems(
            GeneralService<SaleItem>(
              endpoint: "/invoices/sale-items/",
              fromMap: SaleItem.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: Column(
        children: [
          MyContainer(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PermissionGuard(
                  requiredPermissions: ['add_saleitem'],
                  child: CreateNewButton(onPressed: () {}),
                ),
                PermissionGuard(
                  requiredPermissions: ['view_saleitem'],
                  child: MySearchAnchor<SaleItem>(searchIn: sales),
                ),
                // SearchAnchor(
                //   viewBackgroundColor: Colors.white,
                //   viewPadding: EdgeInsets.symmetric(horizontal: 30),
                //   shrinkWrap: true,
                //   builder:
                //       (BuildContext context, SearchController controller) {
                //         return IconButton(
                //           icon: const Icon(Icons.search),
                //           onPressed: () {
                //             // عند النقر على الأيقونة، يتم فتح حقل البحث
                //             controller.openView();
                //           },
                //         );
                //       },
                //   // الدالة المسؤولة عن بناء قائمة الاقتراحات
                //   suggestionsBuilder:
                //       (BuildContext context, SearchController controller) {
                //         // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                //         // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                //         return sales
                //             .where((item) {
                //               return item.toString().toLowerCase().contains(
                //                 controller.text.toLowerCase(),
                //               );
                //             })
                //             .map((item) {
                //               // عرض كل اقتراح كعنصر في القائمة
                //               return ListTile(
                //                 title: Text(item.toString()),
                //                 onTap: () {
                //                   // عند النقر على اقتراح، يتم تحديث حقل البحث
                //                   controller.closeView(item.toString());
                //                 },
                //               );
                //             })
                //             .toList();
                //       },
                // ),
              ],
            ),
          ),
          SizedBox(height: 20),
          PermissionGuard(
            requiredPermissions: ['view_saleitem'],
            fallback: Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
            child: BlocBuilder<GeneralBloc<SaleItem>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(child: Text(state.error));
                } else if (state is ItemsLoadSuccess<SaleItem>) {
                  sales.clear();
                  sales.addAll(state.items);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<SaleItem>(
                    sales,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                    },
                  ),
                  columnsName: SaleItem.columnsName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
