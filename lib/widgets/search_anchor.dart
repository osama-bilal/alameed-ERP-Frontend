// import 'package:flutter/material.dart';

// class MySearchAnchor extends StatefulWidget {
//   const MySearchAnchor({super.key, required this.searchIn});
//   final List<Map<int, String>> searchIn;
//   @override
//   State<MySearchAnchor> createState() => _MySearchAnchorState();
// }

// class _MySearchAnchorState extends State<MySearchAnchor> {
//   @override
//   Widget build(BuildContext context) {
//     return SearchAnchor(
//       isFullScreen: true,
//       viewBackgroundColor: Colors.white,
//       viewPadding: EdgeInsets.symmetric(horizontal: 30),
//       shrinkWrap: true,
//       builder: (BuildContext context, SearchController controller) {
//         return IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: () {
//             // عند النقر على الأيقونة، يتم فتح حقل البحث
//             controller.openView();
//           },
//         );
//       },
//       // الدالة المسؤولة عن بناء قائمة الاقتراحات
//       suggestionsBuilder: (BuildContext context, SearchController controller) {
//         // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
//         return widget.searchIn
//             .where((item) {
//               return item.values.any((element) => element.t.contains(
//                 controller.text.toLowerCase(),
//               );
//             })
//             .map((item) {
//               // عرض كل اقتراح كعنصر في القائمة
//               return ListTile(
//                 title: Text(item["name"]),
//                 onTap: () {
//                   // عند النقر على اقتراح، يتم تحديث حقل البحث
//                   controller.closeView(item['name']);
//                 },
//               );
//             })
//             .toList();
//       },
//     );
//   }
// }
