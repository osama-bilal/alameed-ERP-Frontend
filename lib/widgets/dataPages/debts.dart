import 'package:flutter/material.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DebtPage extends StatelessWidget {
  DebtPage({super.key});
  final List<Debt> debts = List.generate(
    5,
    (i) => Debt(
      partyType: ["Customer", "Supplier", "Employee"][i % 3],
      partyId: i,
      kind: ["product", "cash", "previous"][i % 3],
      amount: (1000.0 - i).toString(),
      paid: i.toString(),
      returned: "0.00",
      status: "unpaid",
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<Debt>()
        ..add(
          LoadItems(
            GeneralService<Debt>(
              endpoint: "/debts/debts/",
              fromMap: Debt.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: BlocBuilder<GeneralBloc<Debt>, GeneralState>(
        builder: (context, state) {
          if (state is GeneralLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ItemLoadFailure) {
            return Center(child: Text('Failed to load debts: ${state.error}'));
          } else if (state is ItemsLoadSuccess<Debt>) {
            debts.clear();
            debts.addAll(state.items);
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
                            return debts
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
                datasource: MyDataSource<Debt>(
                  debts,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
                ),
                columnsName: Debt.columnsName,
              ),
            ],
          );
        },
      ),
    );
  }
}
