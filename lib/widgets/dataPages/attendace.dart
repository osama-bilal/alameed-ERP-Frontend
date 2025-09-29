import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendancePage extends StatelessWidget {
  AttendancePage({super.key});
  final List<Attendance> attendaces = [];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<Attendance>()
        ..add(
          LoadItems(
            GeneralService<Attendance>(
              endpoint: "/employees/attendances/",
              toMap: (o) => o.toMap(),
              fromMap: (o) => Attendance.fromMap(o),
            ),
          ),
        ),
      child: BlocBuilder<GeneralBloc<Attendance>, GeneralState>(
        builder: (context, state) {
          if (state is GeneralLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ItemLoadFailure) {
            return Center(
              child: Text('Failed to load attendaces: ${state.error}'),
            );
          } else if (state is ItemsLoadSuccess<Attendance>) {
            attendaces.clear();
            attendaces.addAll(state.items);
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
                            // فلترة الاقتراحات بناءً على ما يكتبه  المستخدم
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
                    showEditAttendanceDialog(context, o);
                  },
                ),
                columnsName: Attendance.columnsName,
              ),
            ],
          );
        },
      ),
    );
  }
}

// افترض أن هذا هو نموذج الحضور الخاص بك
// class Attendance extends BaseModel { ... }

// الدالة المسؤولة عن إظهار صندوق التعديل
void showEditAttendanceDialog(BuildContext context, Attendance attendance) {
  // Controllers للحقول النصية والرقمية
  final workHoursController = TextEditingController(text: attendance.workHours.toString());
  final lateMinutesController = TextEditingController(text: attendance.lateMinutes.toString());
  final notesController = TextEditingController(text: attendance.notes ?? '');

  // متغيرات لإدارة الحالة داخل الـ Dialog
  DateTime selectedDate = attendance.date;
  bool isPresent = attendance.isPresent;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل سجل الحضور'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // حقل الموظف (للقراءة فقط)
                  // من الأفضل عرض اسم الموظف هنا إذا كان متاحًا
                  Text('معرف الموظف: ${attendance.employeeId}', style: TextStyle(color: Colors.grey.shade700)),
                  Divider(),
                  SizedBox(height: 8),

                  // --- منتقي التاريخ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('التاريخ:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: Icon(Icons.calendar_month, size: 18),
                        label: Text(DateFormat.yMMMMd().format(selectedDate)),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(Duration(days: 30)),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // --- مفتاح الحضور (Switch) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('حاضر؟', style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: isPresent,
                        onChanged: (value) {
                          setState(() {
                            isPresent = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  // -- نعرض هذه الحقول فقط في حالة الحضور --
                  if (isPresent) ...[
                    Divider(),
                    SizedBox(height: 16),
                    TextField(
                      controller: workHoursController,
                      decoration: InputDecoration(labelText: 'ساعات العمل'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: lateMinutesController,
                      decoration: InputDecoration(labelText: 'دقائق التأخير'),
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(labelText: 'ملاحظات (اختياري)'),
                    maxLines: 3,
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
                  attendance.date = selectedDate;
                  attendance.isPresent = isPresent;
                  // إذا كان الموظف حاضرًا، قم بتحديث القيم، وإلا قم بتصفيرها
                  if (isPresent) {
                    attendance.workHours = double.tryParse(workHoursController.text) ?? 0.0;
                    attendance.lateMinutes = int.tryParse(lateMinutesController.text) ?? 0;
                  } else {
                    attendance.workHours = 0.0;
                    attendance.lateMinutes = 0;
                  }
                  attendance.notes = notesController.text.isNotEmpty ? notesController.text : null;
                  
                  // استدعاء دالة الحفظ...
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