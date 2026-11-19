import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/pos%20purch/p_os_bloc.dart';
import '/blocs/pos%20purch/sell/sell_bloc.dart';
import '/controllers/provider/pos_view.dart';
import '/l10n/app_localizations.dart';
import '/models/category.dart';
import '/models/invoices/purchase.dart';
import '/models/pos_view.dart';
import '/screens/purchase%20pos/bill.dart';
import '/screens/purchase%20pos/returning.dart';
import '/screens/purchase%20pos/selling.dart';
import '/widgets/container_head.dart';
import '/widgets/product_card.dart';
import '/widgets/search_anchor.dart';
import '/widgets/shared_content.dart';

// import 'package:provider/provider.dart';

class PosPurchScreen extends StatefulWidget {
  const PosPurchScreen({super.key});

  @override
  State<PosPurchScreen> createState() => _PosPurchScreenState();
}

class _PosPurchScreenState extends State<PosPurchScreen> {
  List<ProductCategory> categories = [];
  String selectedCategory = 'All';
  final _barcodeController = TextEditingController();
  final _returnController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  late final l10n = AppLocalizations.of(context)!;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PosPurchBloc>(context).add(LoadPosData());
      context.read<ProductsProvider>().getFromServer();
    });
    super.initState();
  }

  void _submitBarcode(String barcode) {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return;
    try {
      final product = context.read<ProductsProvider>().pros.firstWhere(
        (p) => p.barcode == trimmed,
      );
      context.read<PosPurchBloc>().add(AddProductToActiveInvoice(product));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productWithBarcode(trimmed))),
      );
    }
    _barcodeController.clear();
  }

  void _submitReturn(String invCode) {
    final trimmed = invCode.trim();
    if (trimmed.isEmpty) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReturnPurchScreen(invCode: trimmed),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _returnController.clear();
  }

  String sortedBy = "name";
  DraggableScrollableController sheetcontroller =
      DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    return BlocBuilder<PosPurchBloc, PosPurchState>(
      builder: (ctx, state) {
        if (state.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("${state.error}")));
          });
        }

        categories = [ProductCategory(name: l10n.all), ...state.categories];
        return BlocListener<PurchBloc, PurchState>(
          listener: (listener, state) {
            if (state is SellingStarted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SellScreen()),
              );
            } else if (state is SellFialed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              });
            } else if (state is Loading) {
              showDialog(
                context: context,
                barrierDismissible: context.read<PurchBloc>().state is Loading,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );
            }
          },
          child: SharedContent(
            activeScreen: "pos",
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<PosPurchBloc>().add(CreateNewInvoice());
              },
              child: Icon(Icons.add),
            ),
            actions: [
              PopupMenuButton<PurchaseInvoice>(
                initialValue: state.activeInvoice,
                itemBuilder: (_) => state.invoices
                    .map(
                      (inv) => PopupMenuItem(
                        value: inv,
                        child: Text("${l10n.invoice}: ${inv.id}"),
                      ),
                    )
                    .toList(),
                onSelected: (inv) =>
                    context.read<PosPurchBloc>().add(SetActiveInvoice(inv)),
                icon: Icon(Icons.receipt_long),
              ),
            ],
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PosPurchBloc>().add(LoadPosData());
              },
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
                                _buildSearchRow(isMobile),
                                SizedBox(height: 20),
                                _buildCategoryList(),
                                SizedBox(height: 10),
                                _buildProductsGrid(useExpanded: false),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          child: DraggableScrollableSheet(
                            controller: sheetcontroller,
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
                          _buildSearchRow(false),
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
                                Expanded(
                                  flex: 2,
                                  child: OrderPanel(
                                    controller: ScrollController(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchRow(bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    if (isMobile) {
      return MyContainer(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      hintText: l10n.scanCode,
                      prefixIcon: const Icon(Icons.qr_code),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => _submitBarcode(_barcodeController.text),
                      ),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    onSubmitted: _submitBarcode,
                  ),
                ),
                const SizedBox(width: 8),
                MySearchAnchor<POSView>(
                  searchIn: context.watch<ProductsProvider>().pros,
                  onSubmitted: (s) {
                    if (s.isNotEmpty) {
                      BlocProvider.of<PosPurchBloc>(
                        context,
                      ).add(AddProductToActiveInvoice(s.first));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _returnController,
              decoration: InputDecoration(
                hintText: l10n.returnString,
                prefixIcon: const Icon(Icons.restore_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _submitReturn(_returnController.text),
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              onSubmitted: _submitReturn,
            ),
          ],
        ),
      );
    }

    return MyContainer(
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: _returnController,
              decoration: InputDecoration(
                hintText: l10n.returnString,
                prefixIcon: const Icon(Icons.restore_rounded),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              onSubmitted: _submitReturn,
            ),
          ),
          const Spacer(),
          MySearchAnchor<POSView>(
            searchIn: context.watch<ProductsProvider>().pros,
            onSubmitted: (s) {
              if (s.isNotEmpty) {
                BlocProvider.of<PosPurchBloc>(
                  context,
                ).add(AddProductToActiveInvoice(s.first));
              }
            },
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                hintText: l10n.scanCode,
                prefixIcon: const Icon(Icons.qr_code),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              onSubmitted: _submitBarcode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid({int? crossAxisCount, required bool useExpanded}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Text(
              l10n.chooseProducts,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: sortedBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.sort),
              items: [
                DropdownMenuItem(value: 'name', child: Text(l10n.nameLabel)),
                DropdownMenuItem(value: 'price', child: Text(l10n.price)),
                DropdownMenuItem(value: 'quantity', child: Text(l10n.quantity)),
                DropdownMenuItem(
                  value: 'category',
                  child: Text(l10n.categoryName),
                ),
                DropdownMenuItem(value: 'brand', child: Text(l10n.brandName)),
              ],
              onChanged: (value) {
                sortedBy = value!;
                if (value == 'name') {
                  context.read<ProductsProvider>().sortBy("name");
                } else if (value == 'price') {
                  context.read<ProductsProvider>().sortBy("price");
                } else if (value == 'quantity') {
                  context.read<ProductsProvider>().sortBy("quantity");
                } else if (value == 'category') {
                  context.read<ProductsProvider>().sortBy("category");
                } else if (value == 'brand') {
                  context.read<ProductsProvider>().sortBy("brand");
                }
              },
            ),
          ],
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
    final filteredProducts = context.watch<ProductsProvider>().filteredProducts(
      selectedCategory,
    );
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
            return ProductCard(
              onTap: () {
                BlocProvider.of<PosPurchBloc>(
                  context,
                  listen: false,
                ).add(AddProductToActiveInvoice(product));
              },
              product: product,
            );
          },
        );
      },
    );
  }
}
