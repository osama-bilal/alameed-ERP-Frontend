// lib/pos_screen.dart
// here we must have a row contain tow columns in desktop display the first column contain the drawer and name of app
// and the second column contain row → the name of user and welcome statement in column and in infront side row contains some tools buttons like dark mode and profile and notifications
// after of those a second row for search tools search button and barcode scanner button and shopping cart button under of they a horizontal list view of categories for filtering products
// then after of all we have a grid view to display the products
// fetch all variants from the server and

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';

class PendingOperation<T> {
  final String type; // "add", "delete", "update"
  final dynamic itemId;
  final T payload;

  PendingOperation(this.type, this.itemId, this.payload);
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Category> categories = [
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

  Set<SaleInvoice> invoices = {
    SaleInvoice(
      id: 1,
      userId: 1,
      status: "draft",
      refundStatus: "not_refunded",
      subtotal: "0.00",
      tax: "0.00",
      discount: "0.00",
      total: "0.00",
      paid: "0.00",
    ),
  };
  SaleInvoice? invoice;
  List<SaleItem> sales = [];
  List<SaleItem> prevSales = [];
  Timer? _syncTimer;
  // List<Function> _pendingOps = [];
  final GeneralService _invoiceService = GeneralService<SaleInvoice>(
    endpoint: "/invoices/sales/",
    fromMap: SaleInvoice.fromMap,
    toMap: (o) => o.toMap(),
  );

  void _createNewInvoice() {
    BlocProvider.of<GeneralBloc<SaleInvoice>>(context).add(
      AddItem(
        _invoiceService,
        SaleInvoice(
          userId: 1,
          status: "draft",
          refundStatus: "not_refunded",
          subtotal: "0.00",
          date: DateTime.now(),
          tax: '0.00',
          discount: "0.00",
          total: "0.00",
          paid: "0.00",
        ),
      ),
    );
  }

  final List<PendingOperation> _pendingOps = [];

  void _scheduleOp(PendingOperation<SaleItem> op) {
    // لو في عملية عكسية، نحذف الاثنين

    if (op.type == "add") {
      final existingDelete = _pendingOps
          .where(
            (o) =>
                o.type == "delete" &&
                (o.payload.variantId == op.payload.variantId ||
                    o.itemId == op.itemId),
          )
          .toList();
      if (existingDelete.isNotEmpty) {
        _pendingOps.removeWhere(
          (o) =>
              (o.payload.variantId == op.payload.variantId ||
              o.itemId == op.itemId),
        );
        return; // تم الإلغاء
      }
    } else if (op.type == "delete") {
      final existingAdd = _pendingOps
          .where(
            (o) =>
                o.type == "add" &&
                (o.payload.variantId == op.payload.variantId ||
                    o.itemId == op.itemId),
          )
          .toList();
      if (existingAdd.isNotEmpty) {
        _pendingOps.removeWhere(
          (o) =>
              (o.payload.variantId == op.payload.variantId ||
              o.itemId == op.itemId),
        );
        return; // تم الإلغاء
      }
    }

    // لو تحديث موجود لنفس العنصر، استبدل بدل الإضافة المتكررة
    if (op.type == "update") {
      final existingAdd = _pendingOps
          .where(
            (o) =>
                o.type == "add" &&
                (o.payload.variantId == op.payload.variantId ||
                    o.itemId == op.itemId),
          )
          .toList();
      if (existingAdd.isNotEmpty) {
        _pendingOps.removeWhere(
          (o) =>
              (o.payload.variantId == op.payload.variantId ||
              o.itemId == op.itemId),
        );
        _scheduleOp(PendingOperation("add", 0, op.payload));
        return;
      }
      _pendingOps.removeWhere(
        (o) =>
            o.type == "update" &&
            (o.payload.variantId == op.payload.variantId ||
                o.itemId == op.itemId),
      );
    }

    _pendingOps.add(op);

    // إعادة ضبط المؤقت
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 5), () {
      for (var o in _pendingOps) {
        try {
          if (o.type == "add") {
            BlocProvider.of<GeneralBloc<SaleItem>>(
              context,
            ).add(AddItem<SaleItem>(salesService, o.payload));
          } else if (o.type == "delete") {
            BlocProvider.of<GeneralBloc<SaleItem>>(
              context,
            ).add(DeleteItem(salesService, o.itemId));
          } else if (o.type == "update") {
            BlocProvider.of<GeneralBloc<SaleItem>>(
              context,
            ).add(UpdateItem<SaleItem>(salesService, o.payload, o.itemId));
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

  final salesService = GeneralService<SaleItem>(
    endpoint: "/invoices/sale-items/",
    fromMap: SaleItem.fromMap,
    toMap: (o) => o.toMap(),
  );

  void addItem(POSView item) {
    if (invoice == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("please selecte invoice first")));
      });
      return;
    }
    final prevItem = sales
        .where((element) => element.variantId == item.id)
        .firstOrNull;
    if (prevItem != null) {
      updateQuantity(prevItem, prevItem.quantity + 1);
      return;
    }
    final tempId = UniqueKey().toString(); // أو UUID
    final newItem = SaleItem(
      tempId: tempId,
      variantId: item.id,
      quantity: 1,
      unitPrice: item.price,
      invoiceId: invoice!.id!,
    );

    setState(() {
      sales.add(newItem);
    });

    _scheduleOp(PendingOperation("add", newItem.variantId, newItem));
  }

  void updateQuantity(SaleItem item, int newQuantity) {
    setState(() {
      item.quantity = newQuantity;
    });

    final updated = SaleItem(
      id: item.id,
      variantId: item.variantId,
      quantity: newQuantity,
      unitPrice: item.unitPrice,
      invoiceId: item.invoiceId,
    );

    _scheduleOp(PendingOperation("update", item.id ?? item.variantId, updated));
  }

  void deleteItem(dynamic idOrTempId) {
    setState(() {
      sales.removeWhere((s) => s.id == idOrTempId || s.tempId == idOrTempId);
    });

    _scheduleOp(
      PendingOperation(
        "delete",
        idOrTempId,
        SaleItem(variantId: 0, quantity: 0, unitPrice: "", invoiceId: 0),
      ),
    );
  }

  void getSales() {
    if (mounted) {
      if (invoice != null) {
        BlocProvider.of<GeneralBloc<SaleItem>>(context).add(
          LoadItems(
            GeneralService<SaleItem>(
              endpoint: "/invoices/sale-items/?invoice=${invoice!.id}",
              fromMap: SaleItem.fromMap,
              toMap: (o) => o.toMap(),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GeneralBloc<SaleInvoice>>(context).add(
        LoadItems<SaleInvoice>(
          GeneralService<SaleInvoice>(
            endpoint: "/invoices/sales/get_drafts/",
            fromMap: SaleInvoice.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
      BlocProvider.of<GeneralBloc<POSView>>(context).add(
        LoadItems(
          GeneralService<POSView>(
            endpoint: "/products/pos/",
            fromMap: POSView.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
      BlocProvider.of<GeneralBloc<Category>>(context).add(
        LoadItems(
          GeneralService<Category>(
            endpoint: "/products/category/",
            fromMap: Category.fromMap,
            toMap: (o) => o.toMap(),
          ),
        ),
      );
    });
    super.initState();
    getSales();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    return BlocBuilder<GeneralBloc<SaleInvoice>, GeneralState>(
      builder: (ctx, state) {
        if (state is GeneralLoadInProgress<SaleInvoice>) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ItemLoadFailure<SaleInvoice>) {
          sales = List.from(prevSales);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل العملية: ${state.error}")),
            );
          });
        } else if (state is ItemsLoadSuccess<SaleInvoice>) {
          invoices = state.items.toSet();
          if (invoice == null) {
            invoice = invoices.last;
            getSales();
          }
        } else if (state is ItemOperationSuccess<SaleInvoice>) {
          invoices.add(state.item);
          if (invoice == null) {
            invoice = state.item;
            getSales();
          }
        }

        return SharedContent(
          activeScreen: "pos",
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewInvoice,
            child: Icon(Icons.add),
          ),
          actions: [
            if (invoices.isNotEmpty)
              PopupMenuButton<SaleInvoice>(
                itemBuilder: (_) => invoices
                    .map(
                      (inv) => PopupMenuItem(
                        value: inv,
                        child: Text("invoice: //${inv.id}"),
                      ),
                    )
                    .toList(),
                onSelected: (inv) => setState(() {
                  invoice = inv;
                  getSales();
                }),
                icon: Icon(Icons.receipt_long),
              ),
          ],
          child: RefreshIndicator(
            onRefresh: () async {},
            child: invoices.isEmpty
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
                            return _buildOrderPanel(controller);
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
                              Expanded(flex: 2, child: _buildOrderPanel(null)),
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

  // تخطيط الشاشات الكبيرة والمتوسطة (سطح المكتب والأجهزة اللوحية)
  // Widget _buildDesktopLayout() {
  //   return;
  // }
  // تخطيط الشاشات الصغيرة (الهواتف)
  // Widget _buildMobileLayout() {
  //   return Stack(
  //     fit: StackFit.expand,
  //     children: [
  //       Column(
  //         children: [
  //           const SizedBox(height: 20),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // دالة بناء قائمة الفئات
  Widget _buildCategoryList() {
    return BlocBuilder<GeneralBloc<Category>, GeneralState>(
      builder: (context, state) {
        if (state is GeneralLoadInProgress<Category>) {
          categories.clear();
          return CircularProgressIndicator();
        } else if (state is ItemLoadFailure<Category>) {
          return Text(state.error);
        } else if (state is ItemsLoadSuccess<Category>) {
          categories = [Category(name: 'All'), ...state.items];
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
          pros.clear();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل العملية: ${state.error}")),
            );
          });
        } else if (state is ItemsLoadSuccess<POSView>) {
          pros.clear();
          pros.addAll(state.items);
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
                return _buildProductCard(product, () => addItem(product));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(POSView product, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
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
  Widget _buildOrderPanel(ScrollController? conttroller) {
    return BlocBuilder<GeneralBloc<SaleItem>, GeneralState>(
      builder: (context, state) {
        if (state is GeneralLoadInProgress<SaleItem>) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ItemLoadFailure<SaleItem>) {
          sales = List.from(prevSales);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل العملية: ${state.error}")),
            );
          });
        } else if (state is ItemsLoadSuccess<SaleItem>) {
          sales = state.items;
        } else if (state is ItemOperationSuccess<SaleItem>) {
          // Replace existing item with the updated item: remove any with same id then add the new one.
          sales.removeWhere(
            (s) =>
                s.invoiceId == state.item.invoiceId &&
                s.variantId == state.item.variantId,
          );
          sales.add(state.item);
        }
        // sales.sort((a, b) => (a.id ?? 1000).compareTo(b.id ?? 1000));
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            controller: conttroller,
            child: Column(
              children: [
                Text(
                  'Order No: ${invoice!.id}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                Wrap(children: sales.map((e) => _buildOrderItem(e)).toList()),
                const Divider(height: 20),
                _buildOrderSummary(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final finalize = GeneralService(
                              endpoint:
                                  "/invoices/sales/${invoice!.id}/finalize/",
                              fromMap: (o) {},
                              toMap: (o) => {},
                            );
                            try {
                              finalize.create(null);
                            } catch (e) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("فشل العملية: $e")),
                                );
                              });
                            }
                            // تنفيذ دفع/تلخيص
                          },
                          child: Text("Checkout"),
                        ),
                      ),
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          // مسح الفاتورة أو إجراءات أخرى
                        },
                        child: Text("Clear"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // الدوال الفرعية الأخرى (تبقى كما هي)
  Widget _buildOrderItem(SaleItem product) {
    final TextEditingController controller = TextEditingController(
      text: product.quantity.toString(),
    );

    void updateQuantity(int q) {
      if (q < 0) q = 0;
      setState(() {
        product.quantity = q;
        this.updateQuantity(product, q);
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              deleteItem(product.id ?? product.tempId);
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

    invoice!.subtotal = fmt(subtotal);
    invoice!.discount = fmt(discountAmount);
    invoice!.tax = fmt(taxAmount);
    invoice!.total = fmt(total);
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
