import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MySearchAnchor<T> extends StatelessWidget {
  const MySearchAnchor({
    super.key,
    required this.searchIn,
    this.onSubmitted,
    this.onRefresh,
    this.itemToString,
  });
  final List<T> searchIn;
  final void Function()? onRefresh;
  final String Function(T)? itemToString;

  final void Function(List<T>)? onSubmitted;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: SearchAnchor(
        shrinkWrap: true,
        viewBuilder: (suggestions) {
          return RefreshIndicator(
            onRefresh: () async {
              if (onRefresh == null) return;
              onRefresh!();
            },
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) => suggestions.elementAt(index),
            ),
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
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
          final String query = controller.text.toLowerCase();
          final isRtl = Directionality.of(context) == TextDirection.rtl;

          return searchIn
              .where((item) {
                final displayString =
                    (itemToString?.call(item) ?? item.toString())
                        .toLowerCase();
                return displayString.contains(query);
              })
              .map((item) {
                // عرض كل اقتراح كعنصر في القائمة
                final displayString =
                    itemToString?.call(item) ?? item.toString();
                return ListTile(
                  title: Text(
                    displayString,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  onTap: () {
                    // عند النقر على اقتراح، يتم تحديث حقل البحث
                    if (onSubmitted != null) {
                      onSubmitted!([item]);
                      controller.closeView(displayString);
                      return;
                    }
                    controller.closeView(displayString);
                  },
                );
              })
              .toList();
        },
        viewOnSubmitted: (s) {
          s = s.trim();
          final res = searchIn.where((element) {
            final displayString =
                (itemToString?.call(element) ?? element.toString())
                    .toLowerCase();
            return displayString.contains(s.toLowerCase());
          }).toList();
          if (onSubmitted != null) {
            onSubmitted!(res);
          }
          context.pop();
        },
      ),
    );
  }
}
