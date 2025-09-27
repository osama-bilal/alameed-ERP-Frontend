import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/transections.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class TransectionsPage extends StatelessWidget {
  TransectionsPage({super.key});
  final List<AccountTransaction> transections = List.generate(
    10,
    (i) => AccountTransaction(
      id: i,
      contentType: i,
      objectId: i,
      amount: "${i * 100.0}",
      transactionType: 'type_${i % 2}',
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<AccountTransaction>()
        ..add(
          LoadItems(
            GeneralService<AccountTransaction>(
              endpoint: "/expenses/accounts/",
              fromMap: AccountTransaction.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: BlocBuilder<GeneralBloc<AccountTransaction>, GeneralState>(
        builder: (context, state) {
          if (state is GeneralLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ItemLoadFailure) {
            return Center(child: Text(state.error));
          } else if (state is ItemsLoadSuccess) {
            transections.clear();
            transections.addAll(state.invoices as List<AccountTransaction>);
          }
          return Column(
            children: [
              MyContainer(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CreateNewButton(onPressed: () {}),
                    SearchAnchor(
                      viewBackgroundColor: Colors.white,
                      viewPadding: EdgeInsets.symmetric(horizontal: 30),
                      shrinkWrap: true,
                      builder:
                          (BuildContext context, SearchController controller) {
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
                            // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                            return transections
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              MyPaginatedDataTable(
                datasource: MyDataSource<AccountTransaction>(
                  transections,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: AccountTransaction.columnsName,
              ),
            ],
          );
        },
      ),
    );
  }
}
