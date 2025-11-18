import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MySearchAnchor<T> extends StatelessWidget {
  const MySearchAnchor({
    super.key,
    required this.searchIn,
    this.onSubmitted,
    this.onRefresh,
  });
  final List<T> searchIn;
  final void Function()? onRefresh;

  final void Function(T?)? onSubmitted;
  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      viewPadding: EdgeInsets.symmetric(horizontal: 30),
      shrinkWrap: true,
      viewBuilder: (suggestions) {
        return RefreshIndicator(
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) => suggestions.elementAt(index),
          ),
          onRefresh: () async {
            if (onRefresh == null) return;
            onRefresh!();
          },
        );
      },
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
                  if (onSubmitted != null) {
                    onSubmitted!(item);
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
        final res = searchIn
            .where(
              (element) =>
                  element.toString().toLowerCase().contains(s.toLowerCase()),
            )
            .toList();
        if (s.isNotEmpty && onSubmitted != null && res.length == 1) {
          onSubmitted!(res[0]);
        } else {
          onSubmitted!(null);
        }
        context.pop();
      },
    );
  }
}
