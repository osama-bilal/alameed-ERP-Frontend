import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/utils/clean_null.dart';
import 'package:provider/provider.dart';

void showEditUserDialog(BuildContext context, User user) {
  // Controllers للحقول النصية
  final firstNameController = TextEditingController(text: user.firstName ?? '');
  final lastNameController = TextEditingController(text: user.lastName ?? '');
  final emailController = TextEditingController(text: user.email ?? '');
  final userName = TextEditingController(text: user.username);
  final selectedGroups = user.groups.toSet();
  final passwordController = TextEditingController();
  var obscureText = true;
  bool tried = false;
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
                  TextField(
                    controller: userName,
                    enabled: user.id == null,
                    decoration: InputDecoration(labelText: 'User Name'),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => obscureText = !obscureText),
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
                  Consumer<AppParties>(
                    builder: (context, appParties, child) {
                      var groups = appParties.groups;
                      if (groups.isEmpty && !tried) {
                        tried = true;
                        appParties.fetchGroups(); // Fetch if not already loaded
                        return const CircularProgressIndicator();
                      }
                      if (groups.isEmpty) {
                        return const Text("no groups found.");
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'المجموعات/الأدوار (اختر واحداً أو أكثر):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: groups.map((grp) {
                              final isSelected = selectedGroups.contains(
                                grp.name,
                              );
                              return FilterChip(
                                label: Text(grp.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedGroups.add(grp.name);
                                    } else {
                                      selectedGroups.remove(grp.name);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
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
                  } else {
                    context.read<GeneralBloc<User>>().add(
                      PartialUpdateItem(
                        changes: cleanNullData(newUser.toMap()),
                        itemId: newUser.id!,
                      ),
                    );
                  }
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
