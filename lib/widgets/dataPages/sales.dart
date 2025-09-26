import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class SaleItemsPage extends StatelessWidget {
  SaleItemsPage({super.key});
  final List<SaleItem> sales = List.generate(
    20,
    (i) => SaleItem(
      variantId: i,
      quantity: i+1,
      unitPrice: (i*(i+1)).toString(),
      invoiceId: i,
    ),
  );
  @override
  Widget build(BuildContext context) {
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
                builder: (BuildContext context, SearchController controller) {
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
                      return sales
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
          datasource: MyDataSource<SaleItem>(
            sales,
            (o) => o.toMap(),
            editObject: (o) {
              // TODO: Here handle edit action
            },
          ),
          columnsName: SaleItem.columnsName,
        ),
      ],
    );
  }
}
