import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/sell/sell_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/screens/returning.dart';
import 'package:ponit_of_sales/widgets/bill.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/product_card.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
// import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<ProductCategory> categories = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<PosBloc>(context).add(LoadPosData());
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
              context.read<PosBloc>().add(AddProductToActiveInvoice(product));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.productWithBarcode(barcode)),
                ),
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
                    ReturnScreen(invCode: barcode),
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

  DraggableScrollableController sheetcontroller =
      DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    return BlocBuilder<PosBloc, PosState>(
      builder: (ctx, state) {
        if (state.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("${state.error}")));
          });
        }

        categories = [ProductCategory(name: 'All'), ...state.categories];
        return BlocListener<SellingBloc, SellingState>(
          listener: (listener, state) {
            if (state is SellingStarted) {
              context.push('/selling').then((value) {
                context.read<PosBloc>().add(LoadPosData());
                sheetcontroller.reset();
              });
            } else if (state is SellFialed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              });
            } else if (state is Loading) {
              showDialog(
                context: context,
                barrierDismissible:
                    context.watch<SellingBloc>().state is Loading,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );
            }
          },
          child: SharedContent(
            activeScreen: "pos",
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<PosBloc>().add(CreateNewInvoice());
              },
              child: Icon(Icons.add),
            ),
            actions: [
              PopupMenuButton<SaleInvoice>(
                initialValue: state.activeInvoice,
                itemBuilder: (_) => state.invoices
                    .map(
                      (inv) => PopupMenuItem(
                        value: inv,
                        child: Text("invoice: ${inv.id}"),
                      ),
                    )
                    .toList(),
                onSelected: (inv) =>
                    context.read<PosBloc>().add(SetActiveInvoice(inv)),
                icon: Icon(Icons.receipt_long),
              ),
            ],
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PosBloc>().add(LoadPosData());
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
                                _buildSearchRow(),
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
                          _buildSearchRow(),
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

  Widget _buildSearchRow() {
        final l10n = AppLocalizations.of(context)!;

    return MyContainer(
      child: Row(
        children: [
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              iconColor: WidgetStatePropertyAll(Colors.black),
            ),
            onPressed: () {
              // open barcodescanner then get the invoice by barcode
              _startReturn();
            },
            label: Text(l10n.returnString, style: TextStyle(color: Colors.black)),
            icon: Icon(Icons.restore_rounded),
          ),
          Spacer(),
          MySearchAnchor<POSView>(
            searchIn: context.watch<ProductsProvider>().pros,
            onSubmitted: (s) {
              if (s.isNotEmpty) {
                BlocProvider.of<PosBloc>(
                  context,
                ).add(AddProductToActiveInvoice(s.first));
              }
            },
          ),
          TextButton.icon(
            onPressed: _scanBarcode,
            label: Text(l10n.scanCode, style: TextStyle(color: Colors.black)),
            icon: Icon(Icons.barcode_reader),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid({int? crossAxisCount, required bool useExpanded}) {
        final l10n = AppLocalizations.of(context)!;
return Column(
      children: [
        Text(
          l10n.chooseProducts,
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
                BlocProvider.of<PosBloc>(
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
