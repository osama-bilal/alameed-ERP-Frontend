import 'package:flutter/material.dart';

class MySearchAnchor<T> extends StatelessWidget {
  const MySearchAnchor({super.key, required this.searchIn});
  final List<T> searchIn;
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width <= 700;
    return SearchAnchor(
      isFullScreen: isMobile,
      viewBackgroundColor: Colors.white,
      viewPadding: EdgeInsets.symmetric(horizontal: 30),
      shrinkWrap: true,
      builder: (BuildContext context, SearchController controller) {
        return IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // عند النقر على الأيقونة، يتم فتح حقل البحث
            controller.openView();
          },
        );
      },
      // الدالة المسؤولة عن بناء قائمة الاقتراحات
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
        return searchIn
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
    );
  }
}
