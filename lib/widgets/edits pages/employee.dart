// الدالة المسؤولة عن إظهار صندوق التعديل
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:provider/provider.dart';

void showEditEmployeeDialog(BuildContext context, Employee employee) {
  // Controllers للحقول النصية
  final firstNameController = TextEditingController(text: employee.firstName);
  final lastNameController = TextEditingController(text: employee.lastName);
  final emailController = TextEditingController(text: employee.email);
  final positionController = TextEditingController(text: employee.position);
  final salaryController = TextEditingController(text: employee.salary);
  // final userAccountIdController = TextEditingController(
  //   text: employee.userAccountId?.toString() ?? '',
  // );
  int? userAccount;
  PartyController partyController = PartyController(context: context);
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
          Future<void> selectDate(
            BuildContext context,
            bool isBirthDate,
          ) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: isBirthDate ? selectedBirthDate : selectedHireDate,
              firstDate: DateTime(1950),
              lastDate: DateTime(2101),
            );
            if (picked != null &&
                picked !=
                    (isBirthDate ? selectedBirthDate : selectedHireDate)) {
              setState(() {
                // هذا الـ setState خاص بالـ StatefulBuilder
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
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'الاسم الأول'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'الاسم الأخير'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: positionController,
                    decoration: InputDecoration(labelText: 'المنصب الوظيفي'),
                  ),
                  SizedBox(height: 16),
                  // --- حقل تاريخ الميلاد ---
                  Text(
                    'تاريخ الميلاد',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMd().format(selectedBirthDate),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: () => selectDate(context, true),
                      ),
                    ],
                  ),
                  Divider(),
                  // --- حقل تاريخ التعيين ---
                  Text(
                    'تاريخ التعيين',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMd().format(selectedHireDate),
                        ),
                      ),
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
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ), // لوحة مفاتيح للأرقام العشرية
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<ViewParty>>(
                    future: partyController.fetchWithEndpoint("users"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error loading Users: ${snapshot.error}');
                      }
                      final sources = snapshot.data ?? [];
                      if (sources.isEmpty) {
                        return const Text("No available User found.");
                      }

                      return DropdownButtonFormField<int>(
                        initialValue: userAccount,
                        hint: const Text('Select User Account'),
                        items: sources.map((source) {
                          return DropdownMenuItem<int>(
                            value: source.id,
                            child: Text(source.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            userAccount = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'User Account',
                        ),
                        validator: (value) =>
                            value == null ? 'Please select User' : null,
                      );
                    },
                  ),
                  // TextField(
                  //   controller: userAccountIdController,
                  //   decoration: InputDecoration(
                  //     labelText: 'معرف حساب المستخدم (اختياري)',
                  //   ),
                  //   keyboardType: TextInputType.number, // لوحة مفاتيح للأرقام
                  // ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('إلغاء'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text(employee.id == null ? "اضافة" : 'تحديث'),
                onPressed: () {
                  // --- منطقة منطق التحديث ---
                  employee.firstName = firstNameController.text;
                  employee.lastName = lastNameController.text;
                  employee.email = emailController.text;
                  employee.position = positionController.text;
                  employee.salary = salaryController.text;
                  employee.birthDate =
                      selectedBirthDate; // استخدام التاريخ المحدث
                  employee.hireDate =
                      selectedHireDate; // استخدام التاريخ المحدث
                  employee.userAccountId = userAccount;
                  context.read<GeneralBloc<Employee>>().add(
                    employee.id == null
                        ? AddItem(employee)
                        : UpdateItem(item: employee, itemId: employee.id!),
                  );
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
