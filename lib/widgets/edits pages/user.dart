import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/services/general_services.dart';

void showEditUserDialog(BuildContext context, User user) {
  // Controllers للحقول النصية
  final firstNameController = TextEditingController(text: user.firstName ?? '');
  final lastNameController = TextEditingController(text: user.lastName ?? '');
  final emailController = TextEditingController(text: user.email ?? '');
  final userName = TextEditingController(text: user.username);
  // لتبسيط التعامل مع قائمة المجموعات (groups) داخل الـ Dialog، نستخدم String مفصولة بفاصلة
  // final groupsStringController = TextEditingController(
  //   text: user.groups.join(', '),
  // );
  final groupsView = MainController<ViewParty>(
    context: context,
    tempService: GeneralService<ViewParty>(
      endpoint: "/parties/groups/",
      fromMap: ViewParty.fromMap,
      toMap: (o) => o.toMap(),
    ),
  );
  final selectedGroups = <String>{};
  groupsView.fethAll();
  final passwordController = TextEditingController();
  var obscureText = true;
  // متغيرات لإدارة الحالة داخل الـ Dialog
  bool isSuperUser = user.isAdmin;
  bool isActive = user.isActive;
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
                  //  user.username.isNotEmpty? Text(
                  //     'اسم المستخدم: ${user.username}',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.grey.shade700,
                  //     ),
                  //   ):
                  TextField(
                    controller: userName,
                    decoration: InputDecoration(labelText: 'User Name'),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  Container(
                    // padding: EdgeInsets.all(16.0),
                    constraints: BoxConstraints(maxWidth: 500),
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffix: IconButton(
                          onPressed: () => setState(()=>obscureText = !obscureText),
                          icon: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      obscureText: obscureText,
                    ),
                  ),
                  SizedBox(height: 16),
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
                  // عرض قائمة اختيار متعددة تستخرج القيم من groupsView.items (مع رجوع احتياطي لحقل نصي)
                  BlocBuilder<GeneralBloc<ViewParty>, GeneralState<ViewParty>>(
                    builder: (ctx, state) {
                      if (state is GeneralLoadInProgress<ViewParty>) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is ItemLoadFailure<ViewParty>) {
                        return Center(
                          child: Text("خطأ في تحميل المجموعات: ${state.error}"),
                        );
                      } else if (state is ItemsLoadSuccess<ViewParty>) {
                        // البيانات محملة بنجاح

                        // اشتق مجموعات مفعلة من النص الحالي (يحفظ بين عمليات إعادة البناء عبر controller)

                        // جلب الأسماء المتوفرة من viewpartyBloc (مع محاولات متعددة لاسم الحقل)
                        // final availableGroups = (state.items).map((g) {
                        //   final d = g as dynamic;
                        //   return d.name ?? d.title ?? d.group ?? g.toString();
                        // }).toList();

                        if (state.items.isEmpty) {
                          // إذا لم تتوفر بيانات بعد، عرض حقل نصي عادي كخيار احتياطي
                          return Text("لا توجد مجموعات متاحة.");
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المجموعات/الأدوار (اختر واحداً أو أكثر):',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.items.map((grp) {
                                final isSelected = selectedGroups.contains(
                                  grp.name,
                                );
                                return FilterChip(
                                  label: Text(grp.toString()),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    // عند تغيير الاختيار، حدّث النص في controller ثم أعد البناء
                                    // final newSet = Set<String>.from(
                                    //   selectedGroups,
                                    // );
                                    if (selected) {
                                      selectedGroups.add(grp.name);
                                    } else {
                                      selectedGroups.remove(grp.name);
                                    }
                                    // groupsStringController.text = newSet.join(
                                    //   ', ',
                                    // );
                                    // استدعاء setState من StatefulBuilder
                                    (ctx as Element).markNeedsBuild();
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8),
                            // عرض الحقل النصي للعرض/تحرير اليدوي (اختياري)، يقرأ من نفس الcontroller
                            // TextField(
                            //   controller: groupsStringController,
                            //   decoration: InputDecoration(
                            //     helperText:
                            //         'يمكنك تعديل القيم نصياً أو عبر الاختيارات أعلاه',
                            //   ),
                            // ),
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                  Divider(),
                  SizedBox(height: 16),

                  // --- مفتاح "مشرف عام" (isSuper) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مشرف عام (Admin User)?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'حساب نشط (Active)?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
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
                child: Text('حفظ التعديلات'),
                onPressed: () {
                  // --- منطقة منطق التحديث ---

                  // 🚨 تنبيه: لا يمكن تحديث الحقول 'final' مباشرة في النموذج
                  // يجب عليك إما أن يكون النموذج (User) قابلاً للتعديل، أو أن تقوم بإعادة إنشاء كائن جديد
                  // مع تمرير البيانات المحدثة إلى دالة الحفظ/API.

                  // 1. تحويل نص المجموعات إلى قائمة (List)

                  // 2. إنشاء كائن User جديد أو Map للبيانات المحدثة
                  // final updatedUserData = {
                  //   'id': user.id,
                  //   'username': user.username, // لا يتغير
                  //   'password': passwordController.text.isNotEmpty
                  //       ? passwordController.text
                  //       : null,
                  //   'firstName': firstNameController.text.isNotEmpty
                  //       ? firstNameController.text
                  //       : null,
                  //   'lastName': lastNameController.text.isNotEmpty
                  //       ? lastNameController.text
                  //       : null,
                  //   'email': emailController.text.isNotEmpty
                  //       ? emailController.text
                  //       : null,
                  //   'groups': selectedGroups.toList(),
                  //   'is_admin': isSuperUser,
                  //   'is_active': isActive,
                  //   // 'permissions' يمكن تحديثها هنا بنفس الطريقة إذا كانت في الواجهة
                  // };
                  final newUser = User(
                    id: user.id,
                    username: userName.text,
                    isActive: isActive,
                    pass: passwordController.text,
                    firstName: firstNameController.text.isNotEmpty
                        ? firstNameController.text
                        : null,
                    lastName: lastNameController.text.isNotEmpty
                        ? lastNameController.text
                        : null,
                    email: emailController.text.isNotEmpty
                        ? emailController.text
                        : null,
                    groups: selectedGroups.map((e) => e.toString()).toList(),
                    isAdmin: isSuperUser,
                  );
                  if (user.id == null) {
                    context.read<GeneralBloc<User>>().add(AddItem(newUser));
                    ;
                    // هنا يجب أن تستدعي دالة حفظ بيانات المستخدم في قاعدة البيانات/API
                    // مثال: api.createUser(newUser);
                  } else {
                    context.read<GeneralBloc<User>>().add(UpdateItem(item: newUser, itemId: newUser.id!));
                    // هنا يجب أن تستدعي دالة تحديث بيانات المستخدم في قاعدة البيانات/API
                    // مثال: api.updateUser(user.id, updatedUserData);
                  }

                  // إذا كنت تستخدم مكتبة إدارة حالة، قد تحتاج إلى استدعاء دالة تحديث الحالة

                  Navigator.of(
                    context,
                  ).pop(); // يمكن إرجاع البيانات المحدثة عند الإغلاق
                },
              ),
            ],
          );
        },
      );
    },
  );
}
