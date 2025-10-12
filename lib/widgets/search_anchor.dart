import 'package:flutter/material.dart';

class MySearchAnchor<T> extends StatelessWidget {
  const MySearchAnchor({super.key, required this.searchIn, this.onSubmitted});
  final List<T> searchIn;
  final void Function(String)? onSubmitted;
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
                  // _controller.
                  // عند النقر على اقتراح، يتم تحديث حقل البحث
                  if (onSubmitted != null) {
                    onSubmitted!(item.toString());
                    controller.closeView(null);
                    return;
                  }
                  controller.closeView(item.toString());
                },
              );
            })
            .toList();
      },
      viewOnSubmitted: (s) {
        s = s.trim();
        if (s != '' && onSubmitted != null) {
          onSubmitted!(s);
        }
      },
    );
  }
}
