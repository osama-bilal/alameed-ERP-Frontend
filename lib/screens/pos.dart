// lib/pos_screen.dart
// here we must have a row contain tow columns in desktop display the first column contain the drawer and name of app
// and the second column contain row → the name of user and welcome statement in column and in infront side row contains some tools buttons like dark mode and profile and notifications
// after of those a second row for search tools search button and barcode scanner button and shopping cart button under of they a horizontal list view of categories for filtering products
// then after of all we have a grid view to display the products
import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';

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
  final List<String> categories = [
    'All',
    'T-shirt',
    'Jeans pant',
    'Shirt',
    'Shoes',
    'Electronics',
  ];

  // متغير لتخزين الفئة المحددة
  String selectedCategory = 'All';

  // دالة لفلترة المنتجات حسب الفئة
  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == 'All') {
      return products;
    } else {
      return products
          .where((product) => product['name'] == selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    var padding = isMobile
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchRow(isMobile),
                  SizedBox(height: 20),
                  _buildCategoryList(),
                  SizedBox(height: 10),
                  _buildMobileLayout(),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSearchRow(isMobile),
                SizedBox(height: 20),
                _buildCategoryList(),
                SizedBox(height: 10),
                Expanded(child: _buildDesktopLayout()),
              ],
            ),
          );
    return SharedContent(activeScreen: "pos", child: padding);
  }

  // دالة بناء قائمة الفئات
  Widget _buildCategoryList() {
    return MyContainer(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchRow(bool fullScreen) {
    return MyContainer(
      // height: 50,
      child: Row(
        children: [
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              iconColor: WidgetStatePropertyAll(Colors.black),
            ),
            onPressed: () {
              // goto summary
            },
            label: Text("Shopping bag", style: TextStyle(color: Colors.black)),
            icon: Icon(Icons.shopping_bag),
          ),
          Spacer(),
          SearchAnchor(
            isFullScreen: fullScreen,
            viewBackgroundColor: Colors.white,
            viewPadding: EdgeInsets.symmetric(horizontal: 30),
            shrinkWrap: true,
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
  Widget _buildDesktopLayout() {
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
    return Column(
      children: [
        _buildProductsGrid(useExpanded: false),
        const SizedBox(height: 20),
        _buildOrderPanel(isMobile: true),
      ],
    );
  }

  // دالة بناء شريط الرأس (تم تعديلها لتكون متجاوبة)

  // دالة بناء شبكة المنتجات (تم تعديلها لتكون ديناميكية)
  Widget _buildProductsGrid({int? crossAxisCount, required bool useExpanded}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
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
              ? NeverScrollableScrollPhysics()
              : ScrollPhysics(), // لمنع التمرير المزدوج
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculatedCrossAxisCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Order No: 125125',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Wrap(
              children: [
                _buildOrderItem(),
                _buildOrderItem(),
                // يمكنك إضافة المزيد من العناصر هنا
              ],
            ),
            const Divider(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 20),
          ],
        ),
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
}
