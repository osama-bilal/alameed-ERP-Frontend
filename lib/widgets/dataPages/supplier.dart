import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class SuppliersPage extends StatelessWidget {
  SuppliersPage({super.key});
  final List<Supplier> suppliers = List.generate(
    5,
    (i) => Supplier(
      id: i,
      name: "Supplier $i",
      email: "Contact $i",
      createdAt: DateTime.now(),
      phone: "713245678",
      address: "Stree $i",
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<Supplier>()
        ..add(
          LoadItems(
            GeneralService<Supplier>(
              endpoint: "/users/suppliers/",
              fromMap: Supplier.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: BlocBuilder<GeneralBloc<Supplier>, GeneralState>(
        builder: (context, state) {
          if (state is GeneralLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ItemLoadFailure) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is ItemsLoadSuccess<Supplier>) {
            suppliers.clear();
            suppliers.addAll(state.items);
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
                            // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                            // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                            return suppliers
                                .where((item) {
                                  return item.toString().toLowerCase().contains(
                                    controller.text.toLowerCase(),
                                  );
                                })
                                .map((item) {
                                  // عرض كل اقتراح كعنصر في القائمة
                                  return ListTile(
                                    title: Text(item.toString()),
                                    onTap: () {
                                      // عند النقر على اقتراح، يتم تحديث حقل البحث
                                      controller.closeView(item.toString());
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
                datasource: MyDataSource<Supplier>(
                  suppliers,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                    showEditSupplierDialog(context, o);
                  },
                ),
                columnsName: Supplier.columnsName,
              ),
            ],
          );
        },
      ),
    );
  }
}


// الدالة المسؤولة عن إظهار صندوق التعديل
void showEditSupplierDialog(BuildContext context, Supplier supplier) {
  // Controllers للاحتفاظ بالبيانات الجديدة
  final nameController = TextEditingController(text: supplier.name);
  final phoneController = TextEditingController(text: supplier.phone);
  final emailController = TextEditingController(text: supplier.email ?? ''); // التعامل مع القيمة الفارغة
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
                decoration: InputDecoration(labelText: 'البريد الإلكتروني (اختياري)'),
                keyboardType: TextInputType.emailAddress, // لوحة مفاتيح للبريد الإلكتروني
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
              supplier.email = emailController.text.isNotEmpty ? emailController.text : null;
              
              // استدعاء دالة الحفظ
              // ... updateSupplierInDatabase(supplier) ...

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
