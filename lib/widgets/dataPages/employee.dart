import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class EmployeePage extends StatelessWidget {
  EmployeePage({super.key});
  final List<Employee> employees = List.generate(
    5,
    (i) => Employee(
      firstName: "first $i",
      lastName: "Last $i",
      birthDate: DateTime.now().add(-Duration(days: 3650)),
      email: "ema${i}l@mail.com",
      position: "$i",
      salary: "1500",
      hireDate: DateTime.now(),
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
                      return employees
                          .where((item) {
                            return item.toString().toLowerCase().contains(
                              controller.text.toLowerCase(),
                            );
                          })
                          .map((item) {
                            // عرض كل اقتراح كعنصر في القائمة
                            return ListTile(
                              title: Text("${item.firstName} ${item.lastName}"),
                              onTap: () {
                                // عند النقر على اقتراح، يتم تحديث حقل البحث
                                controller.closeView(
                                  "${item.firstName} ${item.lastName}",
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
          datasource: MyDataSource(
            employees,
            (o) => o.toMap(),
            excludeFields: [
              'created_at',
              'updated_at',
              'deleted_at',
              'updated_by',
              'created_by',
              'useraccount',
            ],
          ),
          columnsName: Employee.columnsName,
        ),
      ],
    );
  }
}
