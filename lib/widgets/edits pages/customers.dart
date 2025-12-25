// الدالة المسؤولة عن إظهار صندوق التعديل
import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';
import 'package:provider/provider.dart';

void showEditCustomerDialog(BuildContext context, Customer customer) {
  // Controllers للاحتفاظ بالبيانات الجديدة التي يدخلها المستخدم
  final TextEditingController nameController = TextEditingController(
    text: customer.name,
  );
  final TextEditingController phoneController = TextEditingController(
    text: customer.phone,
  );
  final TextEditingController creditLimitController = TextEditingController(
    text: customer.creditLimit,
  );
  final controller = MainController<Customer>(context: context);
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
            Text(AppLocalizations.of(context)!.editCustomerTitle),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.nameLabel,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneLabel,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.emailOptionalLabel,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.addressOptionalLabel,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // حقل الحد الائتماني
              DecimalField(
                hint: AppLocalizations.of(context)!.creditLimitLabel,
                controller: creditLimitController,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.closeButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(
              customer.id != null
                  ? AppLocalizations.of(context)!.updateButton
                  : AppLocalizations.of(context)!.addButton,
            ),
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
              customer.creditLimit = creditLimitController.text;
              if (customer.id == null) {
                controller.createItem(customer);
              } else {
                controller.update(customer.id!, customer);
              }
              context.read<AppParties>().fetchCustomers();
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
