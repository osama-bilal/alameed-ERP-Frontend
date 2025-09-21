import 'package:flutter/material.dart';

// MyDrawer هو Widget مخصص يمثل درج التنقل الجانبي
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: 270,
      child: ListView(
        // إزالة أي Padding من ListView
        padding: EdgeInsets.all(10),
        children: <Widget>[
          // رأس الدرج الذي يحتوي على معلومات أو صورة
          const DrawerHeader(
            // decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'التطبيق',
              style: TextStyle(
                // color: Colors.white,
                fontSize: 24,
                fontFamily: "Noto Sans Arabic",
              ),
            ),
          ),
          // عنصر قائمة قابل للنقر
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.dashboard),
            title: const Text(
              'الرئيسية',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            selected: true,
            selectedTileColor: Colors.lightGreenAccent,
            selectedColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.point_of_sale),
            title: const Text(
              'نقطة المبيعات',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.shopping_bag),
            title: const Text(
              'المبيعات',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.account_balance),
            title: const Text(
              'الحسابات',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.shopping_cart),
            title: const Text(
              'المشتريات',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.people),
            title: const Text(
              'الموارد البشرية والعملاء',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.report),
            title: const Text(
              'التقارير',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى الصفحة الرئيسية
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.settings),
            title: const Text(
              'الإعدادات',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى صفحة الإعدادات
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
          SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: Colors.grey[350],
            leading: const Icon(Icons.info),
            title: const Text(
              'حول',
              style: TextStyle(fontFamily: "Noto Sans Arabic"),
            ),
            onTap: () {
              // TODO: أضف هنا وظيفة الانتقال إلى صفحة "حول التطبيق"
              Navigator.pop(context); // إغلاق الدرج بعد النقر
            },
          ),
        ],
      ),
    );
  }
}
