// lib/pos_screen.dart
// import 'dart:async';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/invoice.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/controllers/sales/invoice.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
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
  late final InvoiceProvider provider;
  late final ProductsProvider proProvider;
  // متغير لتخزين الفئة المحددة
  String selectedCategory = 'All';

  // دالة لفلترة المنتجات حسب الفئة
  List<POSView> get filteredProducts {
    if (selectedCategory == 'All') {
      return proProvider.pros;
    } else {
      return proProvider.pros
          .where((product) => product.category == selectedCategory)
          .toList();
    }
  }

  late final SaleInvoiceController invoiceController;

  void _createNewInvoice() {
    // provider.createNewInvoice();
    invoiceController.createInvoice(SaleInvoice());
  }

  void addItem(POSView item) {
    if (provider.activeInvoice == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("please selecte invoice first")));
      });
      return;
    }

    final tempId = UniqueKey().toString(); // أو UUID
    final newItem = SaleItem(
      tempId: tempId,
      variantId: item.id,
      quantity: 1,
      unitPrice: item.price,
      invoiceId: provider.activeInvoice!.id!,
    );
    _scheduleOp(
      PendingOperation<SaleItem>(
        type: OperationType.add,
        key: tempId,
        payload: newItem,
      ),
    );
    provider.addItem(newItem);
  }

  final List<PendingOperation<SaleItem>> _pendingOps = [];

  Timer? _syncTimer;
  void _scheduleOp(PendingOperation<SaleItem> op) {
    // لو في عملية عكسية، نحذف الاثنين

    if (op.type == OperationType.delete) {
      final existingAdd = _pendingOps
          .where((o) => o.type == OperationType.add && (o.key == op.key))
          .toList();
      if (existingAdd.isNotEmpty) {
        _pendingOps.removeWhere((o) => (o.key == op.key));
        return; // تم الإلغاء
      }
    }

    // لو تحديث موجود لنفس العنصر، استبدل بدل الإضافة المتكررة
    if (op.type == OperationType.update) {
      final existingAdd = _pendingOps
          .where((o) => o.type == OperationType.add && (o.key == op.key))
          .toList();
      if (existingAdd.isNotEmpty) {
        _pendingOps.removeWhere((o) => (o.key == op.key));
        _scheduleOp(
          PendingOperation<SaleItem>(
            type: OperationType.add,
            key: op.key,
            payload: op.payload,
          ),
        );
        return;
      }
      _pendingOps.removeWhere(
        (o) => o.type == OperationType.update && (o.key == op.key),
      );
    }

    _pendingOps.add(op);

    // إعادة ضبط المؤقت
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 5), () {
      for (var o in _pendingOps) {
        try {
          if (o.type == OperationType.add) {
            BlocProvider.of<GeneralBloc<SaleItem>>(
              context,
            ).add(AddItem<SaleItem>(AppService.saleItemService, o.payload));
          } else if (o.type == OperationType.delete) {
            BlocProvider.of<GeneralBloc<SaleItem>>(
              context,
            ).add(DeleteItem(AppService.saleItemService, o.payload.id!));
          } else if (o.type == OperationType.update) {
            BlocProvider.of<GeneralBloc<SaleItem>>(context).add(
              UpdateItem<SaleItem>(
                AppService.saleItemService,
                o.payload,
                o.payload.id!,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("خطأ أثناء مزامنة ${o.type}: $e")),
          );
        }
      }
      _pendingOps.clear();
    });
  }

  late final MainController<POSView> prosController;
  late final MainController<ProductCategory> catesController;
  @override
  void initState() {
    provider = Provider.of<InvoiceProvider>(context, listen: false);
    proProvider = Provider.of<ProductsProvider>(context, listen: false);
    invoiceController = SaleInvoiceController(context: context);
    prosController = MainController<POSView>(
      context: context,
      service: AppService.posViewService,
    );
    catesController = MainController<ProductCategory>(
      context: context,
      service: AppService.categoryService,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      invoiceController.fetchDrafts();
      prosController.fethAll();
      catesController.fethAll();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    return BlocBuilder<GeneralBloc<SaleInvoice>, GeneralState>(
      builder: (ctx, state) {
        if (state is GeneralLoadInProgress<SaleInvoice>) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ItemLoadFailure<SaleInvoice>) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل العملية: ${state.error}")),
            );
          });
        } else if (state is ItemsLoadSuccess<SaleInvoice>) {
          Map<int, SaleInvoice> invoices = {};
          for (var item in state.items) {
            invoices[item.id!] = item;
          }
          provider.invoices = invoices;
          provider.setActive(state.items.last);
        } else if (state is ItemOperationSuccess<SaleInvoice>) {
          if (state.operation == OperationType.add) {
            provider.addInvoice(state.item);
            provider.setActiveInvoice(state.item.id!);
          }
        }

        return SharedContent(
          activeScreen: "pos",
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewInvoice,
            child: Icon(Icons.add),
          ),
          actions: [
            if (provider.allInvoices.isNotEmpty)
              PopupMenuButton<SaleInvoice>(
                itemBuilder: (_) => provider.allInvoices
                    .map(
                      (inv) => PopupMenuItem(
                        value: inv,
                        child: Text("invoice: ${inv.id}"),
                      ),
                    )
                    .toList(),
                onSelected: (inv) => provider.setActiveInvoice(inv.id!),
                // invoice = inv;
                // getSales();
                icon: Icon(Icons.receipt_long),
              ),
          ],
          child: RefreshIndicator(
            onRefresh: () async {},
            child: provider.allInvoices.isEmpty
                ? Center(child: Text("Create invoice First"))
                : isMobile
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
                        _buildSearchRow(isMobile),
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
    return BlocBuilder<GeneralBloc<ProductCategory>, GeneralState>(
      builder: (context, state) {
        if (state is GeneralLoadInProgress<ProductCategory>) {
          categories.clear();
          return CircularProgressIndicator();
        } else if (state is ItemLoadFailure<ProductCategory>) {
          return Text(state.error);
        } else if (state is ItemsLoadSuccess<ProductCategory>) {
          categories = [ProductCategory(name: 'All'), ...state.items];
        }
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
                        ? Colors.lightBlueAccent
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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
            searchIn: proProvider.pros,
            onSubmitted: (s) {
              addItem(
                proProvider.pros.singleWhere(
                  (element) => element.toString() == s,
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
          _buildGridContent(crossAxisCount: crossAxisCount),
      ],
    );
  }

  // دالة جديدة لبناء محتوى الشبكة
  Widget _buildGridContent({int? crossAxisCount, bool isMobile = true}) {
    return BlocBuilder<GeneralBloc<POSView>, GeneralState>(
      builder: (context, state) {
        if (state is GeneralLoadInProgress<POSView>) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ItemLoadFailure<POSView>) {
          // pros.clear();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل العملية: ${state.error}")),
            );
          });
        } else if (state is ItemsLoadSuccess<POSView>) {
          proProvider.pros = state.items;
          // proProvider.pros.clear();
          // proProvider.pros.addAll(state.items);
        }
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
      },
    );
  }

  Widget _buildProductCard(POSView product) {
    return GestureDetector(
      onTap: () {
        // setState(() {
        provider.addItem(
          SaleItem(
            id: DateTime.now().millisecondsSinceEpoch,
            variantId: product.id,
            unitPrice: product.price,
            invoiceId: provider.activeInvoice!.id!,
          ),
        );
        // });
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
