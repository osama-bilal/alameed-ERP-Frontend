import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/shift.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class ShiftsPage extends StatelessWidget {
  ShiftsPage({super.key});
  final List<Shift> shifts = List.generate(
    5,
    (i) => Shift(
      openedAt: DateTime.now().subtract(Duration(hours: i)),
      closedAt: DateTime.now(),
      openingBalance: "${i * 100}",
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<Shift>()
        ..add(
          LoadItems(
            GeneralService<Shift>(
              endpoint: "/users/shifts/",
              fromMap: Shift.fromMap,
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
                  requiredPermissions: ['add_shift'],
                  child: CreateNewButton(onPressed: () {}),
                ),
                PermissionGuard(
                  requiredPermissions: ['view_shift'],
                  child: MySearchAnchor<Shift>(searchIn: shifts),
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
                //         return shifts
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
            requiredPermissions: ['view_shift'],
            fallback: Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
            child: BlocBuilder<GeneralBloc<Shift>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(child: Text(state.error));
                } else if (state is ItemsLoadSuccess<Shift>) {
                  shifts.clear();
                  shifts.addAll(state.items);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<Shift>(
                    shifts,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                      showEditShiftDialog(context, o);
                    },
                  ),
                  columnsName: Shift.columnsName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showEditShiftDialog(BuildContext context, Shift shift) {
  // Controllers للحقول النصية
  final openingBalanceController = TextEditingController(text: shift.openingBalance);
  final countedCashController = TextEditingController(text: shift.countedCash);
  
  // حقل للملاحظات يمكن استخدامه لـ 'expectedCash' أو حقل إضافي
  // سنستخدمه هنا لـ 'countedCash' وسنعتبر 'expectedCash' للقراءة فقط
  final expectedCashDisplay = shift.expectedCash;

  // متغيرات لإدارة الحالة داخل الـ Dialog
  // نستخدم تاريخ ووقت الفتح كمعيار زمني
  DateTime selectedDate = shift.openedAt ?? DateTime.now(); 
  bool shouldProcessAsAttendance = shift.processedAsAttendance;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل بيانات الوردية #${shift.id ?? 'جديدة'}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- معلومات الوردية الأساسية ---
                  Text('تم الفتح بواسطة: ${shift.openedById ?? 'غير محدد'}', style: TextStyle(color: Colors.grey.shade700)),
                  Text('حالة الإغلاق: ${shift.isClosed ? 'مغلقة' : 'مفتوحة'}', style: TextStyle(color: shift.isClosed ? Colors.red : Colors.green)),
                  Divider(),
                  SizedBox(height: 8),

                  // --- عرض التاريخ (وقت الفتح) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('تاريخ الفتح:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('yyyy/MM/dd HH:mm').format(selectedDate)),
                      // 💡 هنا يمكنك إضافة منتقي الوقت/التاريخ إذا كنت تريد تعديل وقت الفتح
                    ],
                  ),
                  SizedBox(height: 16),

                  // --- مفتاح "معالجة كحضور" (Switch) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('معالجة كحضور؟', style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: shouldProcessAsAttendance,
                        onChanged: (value) {
                          setState(() {
                            shouldProcessAsAttendance = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  // --- حقول المبالغ النقدية ---
                  Divider(),
                  SizedBox(height: 16),

                  // الرصيد الافتتاحي (Opening Balance)
                  TextField(
                    controller: openingBalanceController,
                    decoration: InputDecoration(labelText: 'الرصيد الافتتاحي (نقدية البداية)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 8),

                  // النقدية المتوقعة (Expected Cash) - للقراءة فقط
                  Text('النقدية المتوقعة (مبيعات): ${expectedCashDisplay}', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                  SizedBox(height: 8),


                  // النقدية المعدودة (Counted Cash)
                  TextField(
                    controller: countedCashController,
                    decoration: InputDecoration(labelText: 'النقدية المعدودة (عند الإغلاق)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(child: Text('إلغاء'), onPressed: () => Navigator.of(context).pop()),
              ElevatedButton(
                child: Text('حفظ التعديلات'),
                onPressed: () {
                  // --- منطقة منطق التحديث ---
                  
                  // تحديث حقل المعالجة كحضور
                  shift.processedAsAttendance = shouldProcessAsAttendance;
                  
                  // تحديث الحقول النقدية
                  // نستخدم 'tryParse' للتأكد من أنها قيمة صالحة، ونعيدها إلى String
                  final newOpeningBalance = double.tryParse(openingBalanceController.text) ?? 0.0;
                  final newCountedCash = double.tryParse(countedCashController.text) ?? 0.0;
                  
                  shift.openingBalance = newOpeningBalance.toStringAsFixed(2);
                  shift.countedCash = newCountedCash.toStringAsFixed(2);
                  
                  // 💡 هنا يجب أن تستدعي دالة حفظ بيانات الـ Shift في قاعدة البيانات
                  // على سبيل المثال: api.updateShift(shift);
                  
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