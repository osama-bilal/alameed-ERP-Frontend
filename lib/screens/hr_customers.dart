import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/drawer.dart';
import 'package:ponit_of_sales/widgets/app_bar.dart';
import 'package:ponit_of_sales/widgets/painated_table.dart';

class HRScreen extends StatefulWidget {
  const HRScreen({super.key});

  @override
  State<HRScreen> createState() => HRScreenState();
}

class HRScreenState extends State<HRScreen> {
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
  final List<Employee> employees = List.generate(
    5,
    (i) => Employee(
      firstName: "first $i",
      lastName: "Last $i",
      birthDate: DateTime.now().add(-Duration(days: 3650)),
      email: "ema${i}l@mail.com",
      position: "$i",
      salary: "1500",
      hireDate: DateTime.now(),
    ),
  );
  final tabs = ["Customers", "Employees", "Attenance Tracking"];
  String selectedTab = "Customers";
  String? sortBy = 'ID';
  List get data => selectedTab == "Customers" ? customers : employees;

  @override
  Widget build(BuildContext context) {
    var columns = selectedTab == "Customers"
        ? Customer.columnsName
        : Employee.columnsName;
    bool isLargeScreen = MediaQuery.sizeOf(context).width >= 1100;

    Widget desktopView = Scaffold(
      appBar: MyHeader(),
      backgroundColor: Colors.grey[200],
      drawer: isLargeScreen ? null : MyDrawer(activePage: "hr",),
      body: Row(
        children: [
          if (isLargeScreen) MyDrawer(activePage: "hr",),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // MyHeader(),
                  SizedBox(height: 10),
                  MyContainer(child: _buildTabs()),
                  SizedBox(height: 10),
                  MyContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$selectedTab List",
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          children: [
                            SearchAnchor(
                              // isFullScreen: true,
                              viewBackgroundColor: Colors.white,
                              viewPadding: EdgeInsets.symmetric(horizontal: 30),
                              shrinkWrap: true,
                              builder:
                                  (
                                    BuildContext context,
                                    SearchController controller,
                                  ) {
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
                                  (
                                    BuildContext context,
                                    SearchController controller,
                                  ) {
                                    // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                                    // يجب ربطه بالسيرفر وجعله يبحث في السيرفر او قاعدة البيانات المحلية
                                    return customers
                                        .where((item) {
                                          return item.name
                                              .toLowerCase()
                                              .contains(
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
                            DropdownMenu(
                              initialSelection: sortBy,
                              onSelected: (value) {
                                setState(() {
                                  sortBy = value!.toLowerCase().replaceAll(
                                    " ",
                                    "_",
                                  );
                                });
                              },
                              dropdownMenuEntries: columns
                                  .map(
                                    (e) => DropdownMenuEntry(
                                      value: e.toLowerCase(),
                                      label: e,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        
                        child: MyPaginatedDataTable(
                          datasource: MyDataSource(
                            data,
                            (o) => o.toMap(),
                            excludeFields: [
                              'created_at',
                              'updated_at',
                              'deleted_at',
                              'updated_by',
                              'created_by',
                              'useraccount',
                            ],
                          ),
                          columnsName: columns,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return desktopView;
  }

  Widget _buildTabs() {
    return Row(
      children: tabs.map((tab) {
        final isSelected = tab == selectedTab;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = tab;
              });
            },
            child: Column(
              children: [
                Text(
                  tab,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.green : Colors.black,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 2,
                    width: 30,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
