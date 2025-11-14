import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:provider/provider.dart';

void showEditAttendanceDialog(BuildContext context, Attendance attendance) {
  // Controllers للحقول النصية والرقمية
  final workHoursController = TextEditingController(
    text: attendance.workHours.toString(),
  );
  final lateMinutesController = TextEditingController(
    text: attendance.lateMinutes.toString(),
  );
  final notesController = TextEditingController(text: attendance.notes);
  bool tried = false;

  // متغيرات لإدارة الحالة داخل الـ Dialog
  DateTime selectedDate = attendance.date;
  bool isPresent = attendance.isPresent;
  showDialog(
    barrierDismissible: false,
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
                  Consumer<AppParties>(
                    builder: (context, appParties, snapshot) {
                      final employees = appParties.employees;
                      if (employees.isEmpty && !tried) {
                        tried = true;
                        appParties.fetchEmployees();
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (employees.isEmpty) {
                        return const Text("No employees found.");
                      }
                      return DropdownButtonFormField<int>(
                        errorBuilder: (context, errorText) => Text(errorText),
                        initialValue: attendance.employeeId,
                        hint: const Text('اختر الموظف'),
                        items: context.watch<AppParties>().employees.map((
                          employee,
                        ) {
                          return DropdownMenuItem<int>(
                            value: employee.id,
                            child: Text(employee.name),
                          );
                        }).toList(),
                        onChanged: null,
                        decoration: const InputDecoration(labelText: 'الموظف'),
                      );
                    },
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  // --- منتقي التاريخ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التاريخ:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      Text(
                        'حاضر؟',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
              TextButton(
                child: Text('إلغاء'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text('تحديث'),
                onPressed: () {
                  // --- منطقة منطق التحديث ---
                  attendance.date = selectedDate;
                  attendance.isPresent = isPresent;
                  // إذا كان الموظف حاضرًا، قم بتحديث القيم، وإلا قم بتصفيرها
                  if (isPresent) {
                    attendance.workHours =
                        int.tryParse(workHoursController.text) ?? 0;
                    attendance.lateMinutes =
                        int.tryParse(lateMinutesController.text) ?? 0;
                  } else {
                    attendance.workHours = 0;
                    attendance.lateMinutes = 0;
                  }
                  attendance.notes = notesController.text.isNotEmpty
                      ? notesController.text
                      : null;
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

void showCreateAttendanceDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const _CreateAttendanceDialogContent();
    },
  );
}

class _CreateAttendanceDialogContent extends StatefulWidget {
  const _CreateAttendanceDialogContent();

  @override
  State<_CreateAttendanceDialogContent> createState() =>
      _CreateAttendanceDialogContentState();
}

class _CreateAttendanceDialogContentState
    extends State<_CreateAttendanceDialogContent> {
  final workHoursController = TextEditingController(text: '8.0');
  final lateMinutesController = TextEditingController(text: '0');
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isPresent = true;
  int? selectedEmployeeId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  bool _tried = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة سجل حضور جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Employee Dropdown ---
            Consumer<AppParties>(
              builder: (context, appParties, snapshot) {
                final employees = appParties.employees;
                if (employees.isEmpty && !_tried) {
                  _tried = true;
                  appParties.fetchEmployees();
                  return const Center(child: CircularProgressIndicator());
                }
                if (employees.isEmpty) {
                  return const Text("No employees found.");
                }
                return DropdownButtonFormField<int>(
                  errorBuilder: (context, errorText) => Text(errorText),
                  initialValue: selectedEmployeeId,
                  hint: const Text('اختر الموظف'),
                  items: context.watch<AppParties>().employees.map((employee) {
                    return DropdownMenuItem<int>(
                      value: employee.id,
                      child: Text(employee.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEmployeeId = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'الموظف'),
                );
              },
            ),
            const SizedBox(height: 16),
            // --- Date Picker ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'التاريخ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(DateFormat.yMMMMd().format(selectedDate)),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
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
            const SizedBox(height: 8),
            // --- Presence Switch ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'حاضر؟',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
            if (isPresent) ...[
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: workHoursController,
                decoration: const InputDecoration(labelText: 'ساعات العمل'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lateMinutesController,
                decoration: const InputDecoration(labelText: 'دقائق التأخير'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('إضافة'),
          onPressed: () {
            if (selectedEmployeeId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء اختيار موظف أولاً')),
              );
              return;
            }
            final newAttendance = Attendance(
              employeeId: selectedEmployeeId!,
              date: selectedDate,
              isPresent: isPresent,
              workHours: isPresent
                  ? int.tryParse(workHoursController.text) ?? 0
                  : 0,
              lateMinutes: isPresent
                  ? int.tryParse(lateMinutesController.text) ?? 0
                  : 0,
              notes: notesController.text.isNotEmpty
                  ? notesController.text
                  : null,
            );
            context.read<GeneralBloc<Attendance>>().add(AddItem(newAttendance));
            log('Creating new attendance: ${newAttendance.toString()}');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
