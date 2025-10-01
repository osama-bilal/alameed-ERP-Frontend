// lib/pos_screen.dart
// here we must have a row contain tow columns in desktop display the first column contain the drawer and name of app
// and the second column contain row → the name of user and welcome statement in column and in infront side row contains some tools buttons like dark mode and profile and notifications
// after of those a second row for search tools search button and barcode scanner button and shopping cart button under of they a horizontal list view of categories for filtering products
// then after of all we have a grid view to display the products
// fetch all variants from the server and

import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<Category> categories = [
    Category(name: "All"),
    ...List.generate(7, (i) => Category(id: i, name: "Category $i")),
  ];
  final List<POSView> pros = List.generate(
    25,
    (i) => POSView(
      id: i,
      name: "Product $i",
      barcode: "${i}100100100",
      price: "${i * 5}",
      cost: "${i * 3}",
      quantity: i,
      brand: "Brand $i",
      category: "Category ${i % 7}",
    ),
  );
  // متغير لتخزين الفئة المحددة
  String selectedCategory = 'All';

  // دالة لفلترة المنتجات حسب الفئة
  List<POSView> get filteredProducts {
    if (selectedCategory == 'All') {
      return pros;
    } else {
      return pros
          .where((product) => product.category == selectedCategory)
          .toList();
    }
  }

  final SaleInvoice invoice = SaleInvoice(
    id: 1,
    userId: 1,
    status: "draft",
    refundStatus: "not_refunded",
    subtotal: "0.00",
    tax: "0.00",
    discount: "0.00",
    total: "0.00",
    paid: "0.00",
  );

  final List<SaleItem> sales = [];
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
    return SharedContent(
      activeScreen: "pos",
      child: RefreshIndicator(onRefresh: () async {}, child: padding),
    );
  }

  // دالة بناء قائمة الفئات
  Widget _buildCategoryList() {
    return MyContainer(
      height: 60,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category.name;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category.name;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.lightBlueAccent : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
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
          MySearchAnchor<POSView>(
            searchIn: pros,
            onSubmitted: (s) {
              addItem(pros.singleWhere((element) => element.toString() == s));
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
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildProductsGrid(useExpanded: true)),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _buildOrderPanel(isMobile: false)),
      ],
    );
  }

  // تخطيط الشاشات الصغيرة (الهواتف)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildOrderPanel(isMobile: true),
        const SizedBox(height: 20),
        _buildProductsGrid(useExpanded: false),
      ],
    );
  }

  // دالة بناء شبكة المنتجات (تم تعديلها لتكون ديناميكية)
  Widget _buildProductsGrid({int? crossAxisCount, required bool useExpanded}) {
    return Column(
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

  void addItem(POSView item) {
    sales.add(
      SaleItem(
        variantId: item.id,
        quantity: 1,
        unitPrice: item.price,
        invoiceId: invoice.id!,
      ),
    );
    setState(() {});
  }

  Widget _buildProductCard(POSView product) {
    return GestureDetector(
      onTap: () {
        addItem(product);
      },
      child: Card(
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
                  child: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand),
                  const SizedBox(height: 5),
                  Text(
                    'Code: ${product.barcode}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    'Available: ${product.quantity}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Text(
              'Order No: ${invoice.id}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Wrap(children: sales.map((e) => _buildOrderItem(e)).toList()),
            const Divider(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // الدوال الفرعية الأخرى (تبقى كما هي)
  Widget _buildOrderItem(SaleItem product) {
    final TextEditingController controller = TextEditingController(
      text: product.quantity.toString(),
    );

    void updateQuantity(int q) {
      if (q < 0) q = 0;
      product.quantity = q;
      controller.text = q.toString();
      setState(() {});
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              sales.remove(product);
              setState(() {});
            },
            icon: Icon(Icons.delete),
          ),
          Expanded(
            child: Text(
              pros
                  .singleWhere((element) => element.id == product.variantId)
                  .name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  int current =
                      int.tryParse(controller.text) ?? product.quantity;
                  if (current > 1) {
                    updateQuantity(current - 1);
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    final current = int.tryParse(value);
                    if (current != null && current >= 0) {
                      updateQuantity(current);
                    }
                  },
                  onSubmitted: (value) {
                    final current = int.tryParse(value) ?? product.quantity;
                    updateQuantity(current);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  int current =
                      int.tryParse(controller.text) ?? product.quantity;
                  updateQuantity(current + 1);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            '\$${double.tryParse(product.unitPrice)?.toStringAsFixed(2) ?? product.unitPrice}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    // dynamic calculation variables
    final double discountPercent = 0.0;
    final double taxPercent = 0.0;

    double subtotal = 0;
    for (var e in sales) {
      final price = double.tryParse(e.unitPrice) ?? 0.0;
      subtotal += price * e.quantity;
    }

    final double discountAmount = subtotal * (discountPercent / 100);
    final double taxedBase = subtotal - discountAmount;
    final double taxAmount = taxedBase * (taxPercent / 100);
    final double total = taxedBase + taxAmount;
    String fmt(double v) => v.toStringAsFixed(2);

    invoice.subtotal = fmt(subtotal);
    invoice.discount = fmt(discountAmount);
    invoice.tax = fmt(taxAmount);
    invoice.total = fmt(total);
    return Column(
      children: [
        _buildSummaryRow('Subtotal', '\$${fmt(subtotal)}'),
        _buildSummaryRow(
          'Discount (${fmt(discountPercent)}%)',
          '-\$${fmt(discountAmount)}',
        ),
        _buildSummaryRow('Tax (${fmt(taxPercent)}%)', '\$${fmt(taxAmount)}'),
        const Divider(),
        _buildSummaryRow('Total Amount', '\$${fmt(total)}', isTotal: true),
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
