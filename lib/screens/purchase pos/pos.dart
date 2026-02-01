import 'dart:io';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ponit_of_sales/blocs/pos%20purch/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/pos%20purch/sell/sell_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/screens/purchase%20pos/bill.dart';
import 'package:ponit_of_sales/screens/purchase%20pos/returning.dart';
import 'package:ponit_of_sales/screens/purchase%20pos/selling.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/product_card.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
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

  @override
  void dispose() {
    _barcodeController.dispose();
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

  Future<void> requestCameraPermissions() async {
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
  }

  Future<void> _scanBarcode() async {
    final l10n = AppLocalizations.of(context)!;

    await requestCameraPermissions();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
          cameraSwitchIcon: Icons.change_circle_outlined,
          galleryIcon: Icons.photo,
          flashOnIcon: Icons.flash_on,
          flashOffIcon: Icons.flash_off,
          onDetect: (BarcodeCapture capture) {
            if (capture.barcodes.isEmpty) {
              debugPrint('No barcode detected');
              return;
            }

            final String barcode = capture.barcodes.first.rawValue ?? "";
            if (barcode.isEmpty) {
              return;
            }

            try {
              final product = context.read<ProductsProvider>().pros.firstWhere(
                (p) => p.barcode == barcode,
              );
              context.read<PosPurchBloc>().add(
                AddProductToActiveInvoice(product),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.productWithBarcode(barcode))),
              );
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _startReturn() async {
    await requestCameraPermissions();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          cameraSwitchIcon: Icons.change_circle_outlined,
          galleryIcon: Icons.photo,
          flashOnIcon: Icons.flash_on,
          flashOffIcon: Icons.flash_off,
          onDetect: (BarcodeCapture capture) {
            if (capture.barcodes.isEmpty) {
              debugPrint('No barcode detected');
              return;
            }

            final String barcode = capture.barcodes.first.rawValue ?? "";
            if (barcode.isEmpty) {
              return;
            }
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ReturnPurchScreen(invCode: barcode),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation.drive(
                          CurveTween(curve: Curves.easeInOut),
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
      ),
    );
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
                                _buildSearchRow(
                                  Platform.isAndroid || Platform.isIOS,
                                ),
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

    return MyContainer(
      child: Row(
        children: [
          isMobile
              ? TextButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                    iconColor: const WidgetStatePropertyAll(Colors.black),
                  ),
                  onPressed: () {
                    // open barcodescanner then get the invoice by barcode
                    _startReturn();
                  },
                  label: Text(
                    l10n.returnString,
                    style: const TextStyle(color: Colors.black),
                  ),
                  icon: const Icon(Icons.restore_rounded),
                )
              : SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.returnString,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    onSubmitted: (barcode) {
                      if (barcode.isEmpty) {
                        return;
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ReturnPurchScreen(invCode: barcode),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation.drive(
                                    CurveTween(curve: Curves.easeInOut),
                                  ),
                                  child: child,
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
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
          const SizedBox(width: 8),
          isMobile
              ? TextButton.icon(
                  onPressed: _scanBarcode,
                  label: Text(
                    l10n.scanCode,
                    style: const TextStyle(color: Colors.black),
                  ),
                  icon: const Icon(Icons.barcode_reader),
                )
              : SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      hintText: l10n.scanCode,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    onSubmitted: (barcode) {
                      if (barcode.isEmpty) {
                        return;
                      }

                      try {
                        final product = context
                            .read<ProductsProvider>()
                            .pros
                            .firstWhere((p) => p.barcode == barcode);
                        context.read<PosPurchBloc>().add(
                          AddProductToActiveInvoice(product),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.productWithBarcode(barcode)),
                          ),
                        );
                      }
                      _barcodeController.clear();
                    },
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
