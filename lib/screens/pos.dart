import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/widgets/bill.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<ProductCategory> categories = [];
  String selectedCategory = 'All';

  List<POSView> pros = [];
  List<POSView> get filteredProducts {
    if (selectedCategory == 'All') {
      return pros;
    } else {
      return pros
          .where((product) => product.category == selectedCategory)
          .toList();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PosBloc>(context).add(LoadPosData());
     });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    return BlocBuilder<PosBloc, PosState>(
      builder: (ctx, state) {
        if (state.products.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل الاتصال بالسيرفر سيتم المحاولة")),
            );
          });
        }
        if (state.invoices.isEmpty) {
          return Center(child: Text("Create invoice First"));
        }
        pros = state.products;
        Provider.of<ProductsProvider>(context, listen: false).pros = pros;
        categories = [ProductCategory(name: 'All'), ...state.categories];
        return SharedContent(
          activeScreen: "pos",
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              BlocProvider.of<PosBloc>(context).add(CreateNewInvoice());
            },
            child: Icon(Icons.add),
          ),
          actions: [
            PopupMenuButton<SaleInvoice>(
              itemBuilder: (_) => state.invoices
                  .map(
                    (inv) => PopupMenuItem(
                      value: inv,
                      child: Text("invoice: ${inv.id}"),
                    ),
                  )
                  .toList(),
              onSelected: (inv) =>
                  BlocProvider.of<PosBloc>(context).add(SetActiveInvoice(inv)),
              icon: Icon(Icons.receipt_long),
            ),
          ],
          child: RefreshIndicator(
            onRefresh: () async {},
            child: isMobile
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildSearchRow(isMobile, pros),
                              SizedBox(height: 20),
                              _buildCategoryList(),
                              SizedBox(height: 10),
                              _buildProductsGrid(useExpanded: false),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.2,
                          maxChildSize: 0.8,
                          minChildSize: 0.15,
                          builder: (context, controller) {
                            return OrderPanel(controller: controller);
                          },
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildSearchRow(isMobile, pros),
                        SizedBox(height: 20),
                        _buildCategoryList(),
                        SizedBox(height: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildProductsGrid(useExpanded: true),
                              ),
                              const SizedBox(width: 20),
                              Expanded(flex: 2, child: OrderPanel()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
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

  Widget _buildSearchRow(bool fullScreen, List<POSView> pros) {
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
              BlocProvider.of<PosBloc>(context).add(
                AddProductToActiveInvoice(
                  pros.singleWhere((element) => element.toString() == s),
                ),
              );
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
          _buildGridContent(crossAxisCount: crossAxisCount),
      ],
    );
  }

  // دالة جديدة لبناء محتوى الشبكة
  Widget _buildGridContent({int? crossAxisCount, bool isMobile = true}) {
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

  Widget _buildProductCard(POSView product) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<PosBloc>(
          context,
        ).add(AddProductToActiveInvoice(product));
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
}
