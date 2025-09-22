import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/drawer.dart';
import 'package:ponit_of_sales/widgets/header.dart';
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
  final tabs = ["Customers", "Employees", "Attenance traching"];
  String selectedTab = "Customers";
  String? sortBy = 'ID';
  late MyDataSource _dataSource;

  @override
  Widget build(BuildContext context) {
    _dataSource = MyDataSource(customers, (o) => o.toMap());
    Widget desktopView = Scaffold(
      body: Row(
        children: [
          MyDrawer(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  MyHeader(),
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
                              isFullScreen: true,
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
                              dropdownMenuEntries: Customer.columnNames
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          // Wrap the table so it can scroll both vertically and horizontally,
                          // and give each column a fixed, easily-tweakable width so columns appear changeable.
                          // For interactive resize you can later replace the fixed widths with drag-handles
                          // or use a 3rd-party package that supports resizable columns.
                          SingleChildScrollView(
                            // vertical scroll for many rows
                            child: PaginatedDataTable(
                              columnSpacing: 20,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              // border: TableBorder.all(
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              headingRowColor: WidgetStatePropertyAll(
                                Colors.grey[350],
                              ),
                              rowsPerPage: 10,
                              columns: Customer.columnNames
                                  .map(
                                    (e) => DataColumn(
                                      columnWidth: MinColumnWidth(
                                        FixedColumnWidth(150),
                                        IntrinsicColumnWidth(),
                                      ),
                                      label: Text(
                                        e,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onSort: (columnIndex, ascending) {
                                        final key = e
                                            .toLowerCase()
                                            .replaceAll(' ', '_');
                                        int compareValues(
                                          dynamic aVal,
                                          dynamic bVal,
                                        ) {
                                          if (aVal == null && bVal == null)
                                            return 0;
                                          if (aVal == null) return -1;
                                          if (bVal == null) return 1;
                                          final aNum = num.tryParse(
                                            aVal.toString(),
                                          );
                                          final bNum = num.tryParse(
                                            bVal.toString(),
                                          );
                                          if (aNum != null && bNum != null) {
                                            return aNum.compareTo(bNum);
                                          }
                                          return aVal
                                              .toString()
                                              .toLowerCase()
                                              .compareTo(
                                                bVal.toString().toLowerCase(),
                                              );
                                        }
                          
                                        setState(() {
                                          // If already sorted by this column, reverse order; otherwise sort ascending.
                                          if (sortBy == key) {
                                            customers.sort((a, b) {
                                              final aVal = a.toMap()[key];
                                              final bVal = b.toMap()[key];
                                              return -compareValues(
                                                aVal,
                                                bVal,
                                              );
                                            });
                                          } else {
                                            customers.sort((a, b) {
                                              final aVal = a.toMap()[key];
                                              final bVal = b.toMap()[key];
                                              return compareValues(
                                                aVal,
                                                bVal,
                                              );
                                            });
                                            sortBy = key;
                                          }
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                              source: _dataSource,
                              // rows: customers
                              //     .map(
                              //       (e) => DataRow(
                              //         cells: e
                              //             .toMap()
                              //             .entries
                              //             .where(
                              //               (element) =>
                              //                   element.key != 'created_at' &&
                              //                   element.key != 'updated_at' &&
                              //                   element.key != 'deleted_at' &&
                              //                   element.key != 'updated_by' &&
                              //                   element.key != 'created_by',
                              //             )
                              //             .map(
                              //               (v) => DataCell(
                              //                 Text(
                              //                   v.value.toString(),
                              //                   overflow:
                              //                       TextOverflow.ellipsis,
                              //                 ),
                              //               ),
                              //             )
                              //             .toList(),
                              //       ),
                              //     )
                              //     .toList(),
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
