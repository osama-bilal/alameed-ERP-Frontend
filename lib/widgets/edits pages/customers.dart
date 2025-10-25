// الدالة المسؤولة عن إظهار صندوق التعديل
import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/customer.dart';

void showEditCustomerDialog(BuildContext context, Customer customer) {
  // Controllers للاحتفاظ بالبيانات الجديدة التي يدخلها المستخدم
  final TextEditingController nameController = TextEditingController(
    text: customer.name,
  );
  final TextEditingController phoneController = TextEditingController(
    text: customer.phone,
  );

  // -- التعديل الرئيسي هنا --
  // نتعامل مع الحقول التي قد تكون فارغة (null)
  // نستخدم '??' لإعطاء قيمة افتراضية (نص فارغ) في حال كانت القيمة null
  final TextEditingController emailController = TextEditingController(
    text: customer.email ?? '',
  );
  final TextEditingController addressController = TextEditingController(
    text: customer.address ?? '',
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('تعديل بيانات العميل'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // حقل الاسم
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // حقل الهاتف
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'الهاتف',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // حقل البريد الإلكتروني
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني (اختياري)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // حقل العنوان
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان (اختياري)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('إغلاق'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('تحديث'),
            onPressed: () {
              // --- هنا تضع منطق تحديث البيانات ---
              // 1. احصل على القيم الجديدة من الـ Controllers
              customer.name = nameController.text;
              customer.phone = phoneController.text;

              // إذا كان النص فارغًا، اجعل القيمة null، وإلا فخذ النص
              customer.email = emailController.text.isNotEmpty
                  ? emailController.text
                  : null;
              customer.address = addressController.text.isNotEmpty
                  ? addressController.text
                  : null;

              // 2. قم باستدعاء الدالة المسؤولة عن الحفظ في قاعدة البيانات
              // ... updateCustomerInApi(customer) ...

              // 3. أغلق صندوق الحوار
              Navigator.of(context).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
      );
    },
  );
}
