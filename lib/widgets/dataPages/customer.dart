import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';

class CustomersPage extends StatelessWidget {
  CustomersPage({super.key});
  final List<Customer> customers = List.generate(
    100,
    (i) => Customer(
      id: i,
      name: "name $i",
      phone: "771177$i",
      email: "ema${i}l@mail.com",
      address: "example street $i",
    ),
  );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralBloc<Customer>()
        ..add(
          LoadItems(
            GeneralService<Customer>(
              endpoint: "/users/customers/",
              fromMap: Customer.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        ),
      child: BlocBuilder<GeneralBloc<Customer>, GeneralState>(
        builder: (context, state) {
          if (state is GeneralLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ItemLoadFailure) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is ItemsLoadSuccess<Customer>) {
            customers.clear();
            customers.addAll(state.items);
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
                            return customers
                                .where((item) {
                                  return item.name.toLowerCase().contains(
                                    controller.text.toLowerCase(),
                                  );
                                })
                                .map((item) {
                                  // عرض كل اقتراح كعنصر في القائمة
                                  return ListTile(
                                    title: Text(item.name),
                                    onTap: () {
                                      // عند النقر على اقتراح، يتم تحديث حقل البحث
                                      controller.closeView(item.name);
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
                datasource: MyDataSource<Customer>(
                  customers,
                  (o) => o.toMap(),
                  editObject: (Customer o) {
                    print(o.toString());
                    //TODO: Handle edit action
                  },
                ),
                columnsName: Customer.columnsName,
              ),
            ],
          );
        },
      ),
    );
  }
}
