import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class UsersPage extends StatelessWidget {
  UsersPage({super.key});
  final List<User> users = List.generate(
    5,
    (i) => User(username: "User $i", email: "user$i@example.com"),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<User>()
        ..add(
          LoadItems(
            GeneralService<User>(
              endpoint: "/users/",
              fromMap: User.fromMap,
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
                  requiredPermissions: ['add_user'],
                  child: CreateNewButton(onPressed: () {}),
                ),
                PermissionGuard(
                  requiredPermissions: ['view_user'],
                  child: MySearchAnchor<User>(searchIn: users),
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
                //         return users
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
            requiredPermissions: ['view_user'],
            fallback: Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
            child: BlocBuilder<GeneralBloc<User>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(child: Text(state.error));
                } else if (state is ItemsLoadSuccess<User>) {
                  users.clear();
                  users.addAll(state.items);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<User>(
                    users,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                      showEditUserDialog(context, o);
                    },
                  ),
                  columnsName: User.columnsName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showEditUserDialog(BuildContext context, User user) {
  // Controllers للحقول النصية
  final firstNameController = TextEditingController(text: user.firstName ?? '');
  final lastNameController = TextEditingController(text: user.lastName ?? '');
  final emailController = TextEditingController(text: user.email ?? '');
  
  // لتبسيط التعامل مع قائمة المجموعات (groups) داخل الـ Dialog، نستخدم String مفصولة بفاصلة
  final groupsStringController = TextEditingController(text: user.groups.join(', '));
  
  // متغيرات لإدارة الحالة داخل الـ Dialog
  bool isSuperUser = user.isSuper ?? false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل بيانات المستخدم: ${user.username}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- حقل اسم المستخدم (للقراءة فقط) ---
                  Text('اسم المستخدم: ${user.username}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  Divider(),
                  SizedBox(height: 8),

                  // --- حقول الاسم والبريد الإلكتروني ---
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
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  
                  // --- حقل المجموعات (الأدوار) ---
                  // 💡 ملاحظة: يجب توجيه المستخدم لإدخال الأدوار مفصولة بفاصلة
                  TextField(
                    controller: groupsStringController,
                    decoration: InputDecoration(
                      labelText: 'المجموعات/الأدوار (مثال: admin, cashier)',
                      helperText: 'افصل بين الأدوار بفاصلة (,) بدون مسافة',
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 16),

                  // --- مفتاح "مشرف عام" (isSuper) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('مشرف عام (Super User)؟', style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: isSuperUser,
                        onChanged: (value) {
                          setState(() {
                            isSuperUser = value;
                          });
                        },
                      ),
                    ],
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
                  
                  // 🚨 تنبيه: لا يمكن تحديث الحقول 'final' مباشرة في النموذج
                  // يجب عليك إما أن يكون النموذج (User) قابلاً للتعديل، أو أن تقوم بإعادة إنشاء كائن جديد
                  // مع تمرير البيانات المحدثة إلى دالة الحفظ/API.
                  
                  // 1. تحويل نص المجموعات إلى قائمة (List)
                  final updatedGroups = groupsStringController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  // 2. إنشاء كائن User جديد أو Map للبيانات المحدثة
                  final updatedUserData = {
                    'id': user.id,
                    'username': user.username, // لا يتغير
                    'firstName': firstNameController.text.isNotEmpty ? firstNameController.text : null,
                    'lastName': lastNameController.text.isNotEmpty ? lastNameController.text : null,
                    'email': emailController.text.isNotEmpty ? emailController.text : null,
                    'groups': updatedGroups,
                    'isSuper': isSuperUser,
                    // 'permissions' يمكن تحديثها هنا بنفس الطريقة إذا كانت في الواجهة
                  };
                  
                  // 💡 هنا يجب أن تستدعي دالة حفظ بيانات المستخدم في قاعدة البيانات/API
                  // مثال: api.updateUser(user.id, updatedUserData);
                  
                  // إذا كنت تستخدم مكتبة إدارة حالة، قد تحتاج إلى استدعاء دالة تحديث الحالة
                  
                  Navigator.of(context).pop(updatedUserData); // يمكن إرجاع البيانات المحدثة عند الإغلاق
                },
              ),
            ],
          );
        },
      );
    },
  );
}