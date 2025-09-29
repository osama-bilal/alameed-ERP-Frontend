import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

class AttendancePage extends StatelessWidget {
  AttendancePage({super.key});
  final List<Attendance> attendaces = [];
  @override
  Widget build(BuildContext context) {
    final permissions = tablePermissions(context, 'attendance');
    return BlocProvider(
      create: (context) => GeneralBloc<Attendance>()
        ..add(
          LoadItems(
            GeneralService<Attendance>(
              endpoint: "/employees/attendances/",
              toMap: (o) => o.toMap(),
              fromMap: (o) => Attendance.fromMap(o),
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
                if (permissions['add']!)
                  CreateNewButton(onPressed: () {})
                else
                  Text("Attendance Table"),
                if (permissions['view']!)
                  MySearchAnchor<Attendance>(searchIn: attendaces),
                //   SearchAnchor(
                //     viewBackgroundColor: Colors.white,
                //     viewPadding: EdgeInsets.symmetric(horizontal: 30),
                //     shrinkWrap: true,
                //     builder:
                //         (BuildContext context, SearchController controller) {
                //           return IconButton(
                //             icon: const Icon(Icons.search),
                //             onPressed: () {
                //               // عند النقر على الأيقونة، يتم فتح حقل البحث
                //               controller.openView();
                //             },
                //           );
                //         },
                //     // الدالة المسؤولة عن بناء قائمة الاقتراحات
                //     suggestionsBuilder:
                //         (BuildContext context, SearchController controller) {
                //           // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                //           // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                //           return attendaces
                //               .where((item) {
                //                 return item.toString().toLowerCase().contains(
                //                   controller.text.toLowerCase(),
                //                 );
                //               })
                //               .map((item) {
                //                 // عرض كل اقتراح كعنصر في القائمة
                //                 return ListTile(
                //                   title: Text(
                //                     "${item.employeeId}, present ${item.isPresent ? "Yes" : "No"} ${dateTimeToIso(item.date)}",
                //                   ),
                //                   onTap: () {
                //                     // عند النقر على اقتراح، يتم تحديث حقل البحث
                //                     controller.closeView(
                //                       "${item.employeeId}, present ${item.isPresent ? "Yes" : "No"} ${dateTimeToIso(item.date)}",
                //                     );
                //                   },
                //                 );
                //               })
                //               .toList();
                //         },
                //   ),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (permissions['view']!)
            BlocBuilder<GeneralBloc<Attendance>, GeneralState>(
              builder: (context, state) {
                if (state is GeneralLoadInProgress) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ItemLoadFailure) {
                  return Center(
                    child: Text('Failed to load attendaces: ${state.error}'),
                  );
                } else if (state is ItemsLoadSuccess<Attendance>) {
                  attendaces.clear();
                  attendaces.addAll(state.items);
                }
                return MyPaginatedDataTable(
                  datasource: MyDataSource<Attendance>(
                    attendaces,
                    (o) => o.toMap(),
                    editObject: (o) {
                      // TODO: Here handle edit action
                    },
                    canDelete: permissions['delete']!,
                    canEdit: permissions['change']!,
                  ),
                  columnsName: Attendance.columnsName,
                );
              },
            )
          else
            Center(
              child: Text("You haven't requierd permission to view this table"),
            ),
        ],
      ),
    );
  }
}
