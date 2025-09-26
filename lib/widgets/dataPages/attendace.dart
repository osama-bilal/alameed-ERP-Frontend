import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class AttendancePage extends StatelessWidget {
  AttendancePage({super.key});
  final List<Attendance> attendaces = List.generate(
    5,
    (i) => Attendance(
      employeeId: i,
      date: DateTime.now().subtract(Duration(days: i)),
      isPresent: i % 2 == 0,
      workHours: i / 12,
      lateMinutes: 0,
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
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                  // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                  return attendaces
                      .where((item) {
                        return item.toString().toLowerCase().contains(
                          controller.text.toLowerCase(),
                        );
                      })
                      .map((item) {
                        // عرض كل اقتراح كعنصر في القائمة
                        return ListTile(
                          title: Text(
                            "${item.employeeId}, present ${item.isPresent ? "Yes" : "No"} ${dateTimeToIso(item.date)}",
                          ),
                          onTap: () {
                            // عند النقر على اقتراح، يتم تحديث حقل البحث
                            controller.closeView(
                              "${item.employeeId}, present ${item.isPresent ? "Yes" : "No"} ${dateTimeToIso(item.date)}",
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
          datasource: MyDataSource<Attendance>(
            attendaces,
            (o) => o.toMap(),
            editObject: (o) {
              // TODO: Here handle edit action
            },
          ),
          columnsName: Attendance.columnsName,
        ),
      ],
    );
  }
}
