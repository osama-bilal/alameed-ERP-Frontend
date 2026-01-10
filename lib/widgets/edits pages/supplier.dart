import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:provider/provider.dart';

void showEditSupplierDialog(BuildContext context, Supplier supplier) {
  // Controllers للاحتفاظ بالبيانات الجديدة
  final nameController = TextEditingController(text: supplier.name);
  final phoneController = TextEditingController(text: supplier.phone);
  final emailController = TextEditingController(
    text: supplier.email ?? '',
  ); // التعامل مع القيمة الفارغة
  final addressController = TextEditingController(text: supplier.address);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تعديل بيانات المورد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم المورد'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone, // لوحة مفاتيح للهاتف
              ),
              SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني (اختياري)',
                ),
                keyboardType:
                    TextInputType.emailAddress, // لوحة مفاتيح للبريد الإلكتروني
              ),
              SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'العنوان'),
                maxLines: 3, // جعل الحقل متعدد الأسطر
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('إلغاء'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('تحديث'),
            onPressed: () {
              // --- منطقة منطق التحديث ---
              supplier.name = nameController.text;
              supplier.phone = phoneController.text;
              supplier.address = addressController.text;
              supplier.email = emailController.text.isNotEmpty
                  ? emailController.text
                  : null;
              context.read<GeneralBloc<Supplier>>().add(
                supplier.id != null
                    ? UpdateItem(item: supplier, itemId: supplier.id!)
                    : AddItem(supplier),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  ).then((_) {
    // تنظيف المتحكمين بعد إغلاق الحوار
    
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
  });
}
