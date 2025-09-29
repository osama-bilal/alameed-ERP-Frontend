import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class PurchaseInvoicePage extends StatelessWidget {
  PurchaseInvoicePage({super.key});
  final List<PurchaseInvoice> invoices = List.generate(
    5,
    (i) => PurchaseInvoice(
      userId: i,
      status: [
        "draft",
        "final",
        "paid",
        "unpaid",
        "partially_paid",
        "cancelled",
      ][i % 6],
      refundStatus: 'not_refunded',
      subtotal: "100.0",
      tax: "10.0",
      discount: "5.0",
      total: "105.0",
      paid: "100",
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<PurchaseInvoice>()
        ..add(
          LoadItems(
            GeneralService<PurchaseInvoice>(
              endpoint: "/invoices/purchase/",
              fromMap: PurchaseInvoice.fromMap,
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
                  requiredPermissions: ['add_purchaseinvoice'],
                  child: CreateNewButton(onPressed: () {}),
                ),
                PermissionGuard(
                  requiredPermissions: ['view_purchaseinvoice'],
                  child: MySearchAnchor<PurchaseInvoice>(searchIn: invoices),
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
                //         return invoices
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
            requiredPermissions: ['view_purchaseinvoice'],
            fallback: Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
            child: BlocBuilder<GeneralBloc<PurchaseInvoice>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(child: Text(state.error));
                } else if (state is ItemsLoadSuccess<PurchaseInvoice>) {
                  invoices.clear();
                  invoices.addAll(state.items);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<PurchaseInvoice>(
                    invoices,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                    },
                  ),
                  columnsName: PurchaseInvoice.columnsName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
