// lib/pos_screen.dart
// here we must have a row contain tow columns in desktop display the first column contain the drawer and name of app
// and the second column contain row → the name of user and welcome statement in column and in infront side row contains some tools buttons like dark mode and profile and notifications
// after of those a second row for search tools search button and barcode scanner button and shopping cart button under of they a horizontal list view of categories for filtering products
// then after of all we have a grid view to display the products
import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/drawer.dart';
import 'package:ponit_of_sales/widgets/search_button.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  // بيانات وهمية للمنتجات
  final List<Map<String, dynamic>> products = [
    {
      'name': 'T-shirt',
      'price': 120.0,
      'code': '123456',
      'available': 200,
      'image': 'https://via.placeholder.com/150', // استبدلها بصور حقيقية
    },
    {
      'name': 'Jeans pant',
      'price': 150.0,
      'code': '123457',
      'available': 150,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Shirt',
      'price': 200.0,
      'code': '123458',
      'available': 180,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'T-shirt',
      'price': 120.0,
      'code': '123456',
      'available': 200,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Jeans pant',
      'price': 150.0,
      'code': '123457',
      'available': 150,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Shirt',
      'price': 200.0,
      'code': '123458',
      'available': 180,
      'image': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width > 1100;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: !isDesktop ? Drawer(child: MyDrawer()) : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1100;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 1100;
          final isMobile = constraints.maxWidth <= 600;

          return Row(
            children: [
              // الشريط الجانبي: يظهر فقط على الشاشات الكبيرة
              if (isLargeScreen) MyDrawer(),
              // المحتوى الرئيسي
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // شريط الرأس
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildSearchRow(),
                      SizedBox(height: 20),
                      // المحتوى المتغير بناءً على حجم الشاشة
                      Expanded(
                        child: isMobile
                            ? _buildMobileLayout()
                            : _buildDesktopLayout(isTablet: isTablet),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchRow() {
    return Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey[350],
      child: Row(
        children: [
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              iconColor: WidgetStatePropertyAll(Colors.black),
            ),
            onPressed: () {},
            label: Text("Shopping bag", style: TextStyle(color: Colors.black)),
            icon: Icon(Icons.shopping_bag),
          ),
          Spacer(),
          SearchButton(),
          TextButton.icon(
            onPressed: () {},
            label: Text("Scan barcode"),
            icon: Icon(Icons.barcode_reader),
          ),
        ],
      ),
    );
  }

  // تخطيط الشاشات الكبيرة والمتوسطة (سطح المكتب والأجهزة اللوحية)
  // تخطيط الشاشات الكبيرة والمتوسطة (سطح المكتب والأجهزة اللوحية)
  Widget _buildDesktopLayout({required bool isTablet}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildProductsGrid(useExpanded: true)),
        const SizedBox(width: 20),
        Expanded(flex: 1, child: _buildOrderPanel(isMobile: false)),
      ],
    );
  }

  // تخطيط الشاشات الصغيرة (الهواتف)
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProductsGrid(useExpanded: false),
          const SizedBox(height: 20),
          _buildOrderPanel(isMobile: true),
        ],
      ),
    );
  }

  // دالة بناء الشريط الجانبي (تبقى كما هي)
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text(
            'Starline',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(Icons.dashboard, 'Dashboard', isSelected: true),
          _buildSidebarItem(Icons.point_of_sale, 'POS'),
          _buildSidebarItem(Icons.shopping_bag, 'Sales'),
          _buildSidebarItem(Icons.account_balance, 'Accounting'),
          _buildSidebarItem(Icons.shopping_cart, 'Purchase'),
          _buildSidebarItem(Icons.people, 'Customers & HR'),
          _buildSidebarItem(Icons.payment, 'Payroll'),
          _buildSidebarItem(Icons.report, 'Reports'),
          const Spacer(),
          _buildSidebarItem(Icons.settings, 'Settings'),
          _buildSidebarItem(Icons.help, 'Help'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title, {
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.lightGreen.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.green : Colors.grey),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء شريط الرأس (تم تعديلها لتكون متجاوبة)
  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = MediaQuery.sizeOf(context).width < 900;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isCompact)
              IconButton(
                onPressed: () {
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  } else {
                    Scaffold.of(context).openDrawer();
                  }
                },
                icon: Icon(Icons.list),
              ),

            if (!isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome, Josiah',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("Here's what happening in your store."),
                ],
              ),
            if (isCompact)
              const Text(
                'Welcome, Josiah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            Spacer(),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SearchAnchor(
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
                          return products
                              .where((item) {
                                return item["name"].toLowerCase().contains(
                                  controller.text.toLowerCase(),
                                );
                              })
                              .map((item) {
                                // عرض كل اقتراح كعنصر في القائمة
                                return ListTile(
                                  title: Text(item["name"]),
                                  onTap: () {
                                    // عند النقر على اقتراح، يتم تحديث حقل البحث
                                    controller.closeView(item['name']);
                                  },
                                );
                              })
                              .toList();
                        },
                  ),
                  // SearchButton(),
                  // Flexible(
                  //   child: Container(
                  //     width: isCompact ? 150 : 300,
                  //     padding: const EdgeInsets.symmetric(horizontal: 15),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(30),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.grey.withValues(alpha: 0.1),
                  //           spreadRadius: 1,
                  //           blurRadius: 5,
                  //         ),
                  //       ],
                  //     ),
                  //     child: const TextField(
                  //       decoration: InputDecoration(
                  //         hintText: 'Search...',
                  //         border: InputBorder.none,
                  //         icon: Icon(Icons.search),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                  if (!isCompact)
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  if (!isCompact)
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {},
                    ),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/logo/logo-no-background.png",
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // دالة بناء شبكة المنتجات (تم تعديلها لتكون ديناميكية)
  Widget _buildProductsGrid({int? crossAxisCount, required bool useExpanded}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        if (useExpanded)
          Expanded(
            child: _buildGridContent(
              crossAxisCount: crossAxisCount,
              isMobile: false,
            ),
          )
        else
          _buildGridContent(crossAxisCount: crossAxisCount, isMobile: true),
      ],
    );
  }

  // دالة جديدة لبناء محتوى الشبكة
  Widget _buildGridContent({int? crossAxisCount, required bool isMobile}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int calculatedCrossAxisCount = crossAxisCount ?? 3;
        if (crossAxisCount == null) {
          if (constraints.maxWidth > 800) {
            calculatedCrossAxisCount = 4;
          } else if (constraints.maxWidth > 500) {
            calculatedCrossAxisCount = 3;
          } else {
            calculatedCrossAxisCount = 2;
          }
        }
        return GridView.builder(
          // إضافة shrinkWrap: true لتجنب الأخطاء داخل ListView/SingleChildScrollView
          shrinkWrap: true,
          physics: isMobile
              ? const NeverScrollableScrollPhysics()
              : ScrollPhysics(), // لمنع التمرير المزدوج
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculatedCrossAxisCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  product['image'],
                  // width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset("assets/logo/logo-no-background.png"),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Code: ${product['code']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Available: ${product['available']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${product['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)
  Widget _buildOrderPanel({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Order No: 125125',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          !isMobile
              ? Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildOrderItem(),
                      _buildOrderItem(),
                      // يمكنك إضافة المزيد من العناصر هنا
                    ],
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildOrderItem(),
                    _buildOrderItem(),
                    // يمكنك إضافة المزيد من العناصر هنا
                  ],
                ),
          const Divider(height: 20),
          _buildOrderSummary(),
          const SizedBox(height: 20),
          // if (showNumberPad) _buildNumberPad(), // إظهار أو إخفاء لوحة الأرقام
        ],
      ),
    );
  }

  // الدوال الفرعية الأخرى (تبقى كما هي)
  Widget _buildOrderItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Image.network(
            'https://via.placeholder.com/50',
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              "assets/logo/logo-no-background.png",
              height: 50,
              width: 50,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Product full name go here',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text('\$200.00', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', '\$85.25'),
        _buildSummaryRow('Discount (5%)', '\$20.00'),
        _buildSummaryRow('Tax (2%)', '\$10.25'),
        _buildSummaryRow('Total Amount', '\$77.00', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildNumberPad() {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     constraints: BoxConstraints(maxHeight: 500),
  //     child: GridView.builder(
  //       shrinkWrap: true,
  //       physics: const NeverScrollableScrollPhysics(),
  //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 3,
  //         crossAxisSpacing: 10,
  //         mainAxisSpacing: 10,
  //         childAspectRatio: 1.5,
  //       ),
  //       itemCount: 12,
  //       itemBuilder: (context, index) {
  //         final buttonText = _getNumberPadText(index);
  //         return ElevatedButton(onPressed: () {}, child: Text(buttonText));
  //       },
  //     ),
  //   );
  // }

  //   String _getNumberPadText(int index) {
  //     if (index < 9) {
  //       return (index + 1).toString();
  //     } else if (index == 9) {
  //       return '0';
  //     } else if (index == 10) {
  //       return '.';
  //     } else {
  //       return '⌫';
  //     }
  //   }
}
