import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:intl/intl.dart'; 
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
    return BlocProvider(
      create: (context) => GeneralBloc<Employee>()
        ..add(
          LoadItems(
            GeneralService<Employee>(
              endpoint: "/employees/employees/",
              fromMap: Employee.fromMap,
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
                  requiredPermissions: ['add_employee'],
                  child: CreateNewButton(onPressed: () {}),
                ),
                PermissionGuard(
                  requiredPermissions: ['view_employee'],
                  child: MySearchAnchor(searchIn: employees),
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
                //         return employees
                //             .where((item) {
                //               return item.toString().toLowerCase().contains(
                //                 controller.text.toLowerCase(),
                //               );
                //             })
                //             .map((item) {
                //               // عرض كل اقتراح كعنصر في القائمة
                //               return ListTile(
                //                 title: Text(
                //                   "${item.firstName} ${item.lastName}",
                //                 ),
                //                 onTap: () {
                //                   // عند النقر على اقتراح، يتم تحديث حقل البحث
                //                   controller.closeView(
                //                     "${item.firstName} ${item.lastName}",
                //                   );
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
            requiredPermissions: ['view_employee'],
            fallback: Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
            child: BlocBuilder<GeneralBloc<Employee>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(child: Text('Error: ${state.error}'));
                } else if (state is ItemsLoadSuccess<Employee>) {
                  employees.clear();
                  employees.addAll(state.items);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<Employee>(
                    employees,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                      showEditEmployeeDialog(context, o);
                    },
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// الدالة المسؤولة عن إظهار صندوق التعديل
void showEditEmployeeDialog(BuildContext context, Employee employee) {
  // Controllers للحقول النصية
  final firstNameController = TextEditingController(text: employee.firstName);
  final lastNameController = TextEditingController(text: employee.lastName);
  final emailController = TextEditingController(text: employee.email);
  final positionController = TextEditingController(text: employee.position);
  final salaryController = TextEditingController(text: employee.salary);
  final userAccountIdController = TextEditingController(text: employee.userAccountId?.toString() ?? '');

  // متغيرات لتخزين التواريخ المحدثة
  DateTime selectedBirthDate = employee.birthDate;
  DateTime selectedHireDate = employee.hireDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // نستخدم StatefulBuilder لتحديث الواجهة  الداخلية للـ Dialog فقط (عند تغيير التاريخ)
      return StatefulBuilder(
        builder: (context, setState) {
          // دالة مساعدة لفتح منتقي التاريخ
          Future<void> selectDate(BuildContext context, bool isBirthDate) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: isBirthDate ? selectedBirthDate : selectedHireDate,
              firstDate: DateTime(1950),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != (isBirthDate ? selectedBirthDate : selectedHireDate)) {
              setState(() { // هذا الـ setState خاص بالـ StatefulBuilder
                if (isBirthDate) {
                  selectedBirthDate = picked;
                } else {
                  selectedHireDate = picked;
                }
              });
            }
          }

          return AlertDialog(
            title: Text('تعديل بيانات الموظف'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'الاسم الأول')),
                  SizedBox(height: 8),
                  TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'الاسم الأخير')),
                  SizedBox(height: 8),
                  TextField(controller: emailController, decoration: InputDecoration(labelText: 'البريد الإلكتروني')),
                  SizedBox(height: 8),
                  TextField(controller: positionController, decoration: InputDecoration(labelText: 'المنصب الوظيفي')),
                  SizedBox(height: 16),
                  
                  // --- حقل تاريخ الميلاد ---
                  Text('تاريخ الميلاد', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  Row(
                    children: [
                      Expanded(child: Text(DateFormat.yMMMMd().format(selectedBirthDate))),
                      IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: () => selectDate(context, true),
                      ),
                    ],
                  ),
                  Divider(),
                  
                  // --- حقل تاريخ التعيين ---
                  Text('تاريخ التعيين', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  Row(
                    children: [
                      Expanded(child: Text(DateFormat.yMMMMd().format(selectedHireDate))),
                      IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: () => selectDate(context, false),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8),

                  TextField(
                    controller: salaryController,
                    decoration: InputDecoration(labelText: 'الراتب'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true), // لوحة مفاتيح للأرقام العشرية
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: userAccountIdController,
                    decoration: InputDecoration(labelText: 'معرف حساب المستخدم (اختياري)'),
                    keyboardType: TextInputType.number, // لوحة مفاتيح للأرقام
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(child: Text('إلغاء'), onPressed: () => Navigator.of(context).pop()),
              ElevatedButton(
                child: Text('تحديث'),
                onPressed: () {
                  // --- منطقة منطق التحديث ---
                  employee.firstName = firstNameController.text;
                  employee.lastName = lastNameController.text;
                  employee.email = emailController.text;
                  employee.position = positionController.text;
                  employee.salary = salaryController.text;
                  employee.birthDate = selectedBirthDate; // استخدام التاريخ المحدث
                  employee.hireDate = selectedHireDate; // استخدام التاريخ المحدث
                  employee.userAccountId = int.tryParse(userAccountIdController.text);

                  // استدعاء دالة الحفظ في قاعدة البيانات أو الـ API
                  // ... updateUser(employee) ...

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}