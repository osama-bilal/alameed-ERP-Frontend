import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/shift.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class ShiftsPage extends StatelessWidget {
  ShiftsPage({super.key});
  final List<Shift> shifts = List.generate(
    5,
    (i) => Shift(openedAt: DateTime.now().subtract(Duration(hours: i)), closedAt: DateTime.now(), openingBalance: "${i * 100}", )
    
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
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                  // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                  return shifts
                      .where((item) {
                        return item.toString().toLowerCase().contains(
                          controller.text.toLowerCase(),
                        );
                      })
                      .map((item) {
                        // عرض كل اقتراح كعنصر في القائمة
                        return ListTile(
                          title: Text(
                            item.toString(),
                          ),
                          onTap: () {
                            // عند النقر على اقتراح، يتم تحديث حقل البحث
                            controller.closeView(
                              item.toString(),
                            );
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
          datasource: MyDataSource<Shift>(
            shifts,
            (o) => o.toMap(),
            editObject: (o) {
              // TODO: Here handle edit action
            },
          ),
          columnsName: Shift.columnsName,
        ),
      ],
    );
  }
}
