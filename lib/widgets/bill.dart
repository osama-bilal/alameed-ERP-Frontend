// دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/invoice.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:provider/provider.dart';

class OrderPanel extends StatefulWidget {
  const OrderPanel({super.key, this.controller});
  final ScrollController? controller;
  @override
  State<OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<OrderPanel> {
  late final ScrollController _controller;
  late final ProductsProvider pros;
  @override
  void initState() {
    _controller = widget.controller ?? ScrollController();

    if (mounted) {
      pros = Provider.of<ProductsProvider>(context, listen: false);
    }
    super.initState();
  }

  void deleteItem(dynamic idOrTempId) {
    Provider.of<InvoiceProvider>(context, listen: false).removeItem(idOrTempId);
    _scheduleOp(
      PendingOperation<SaleItem>(
        type: OperationType.delete,
        key: idOrTempId,
        payload: SaleItem(
          variantId: 0,
          quantity: 0,
          unitPrice: "",
          invoiceId: 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Only dispose the controller if it was created locally.
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void updateQuantity(SaleItem item, int newQuantity) {
    final updated = SaleItem(
      id: item.id,
      variantId: item.variantId,
      quantity: newQuantity,
      unitPrice: item.unitPrice,
      invoiceId: item.invoiceId,
    );

    _scheduleOp(
      PendingOperation<SaleItem>(
        type: OperationType.update,
        key: item.tempId ?? item.id.toString(),
        payload: updated,
      ),
    );
  }

  final List<PendingOperation> _pendingOps = [];

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
            ).add(DeleteItem(AppService.saleItemService, o.payload.id));
          } else if (o.type == OperationType.update) {
            BlocProvider.of<GeneralBloc<SaleItem>>(context).add(
              UpdateItem<SaleItem>(
                AppService.saleItemService,
                o.payload,
                o.payload.id,
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

  @override
  Widget build(BuildContext context) {
    //  else {
    //   return Center(child: Text("Please create Invoice First"));
    // }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: [
            Text(
              'Order No: ${context.watch<InvoiceProvider>().activeInvoice!.id}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Wrap(
              children: context
                  .watch<InvoiceProvider>()
                  .activeInvoice!
                  .items
                  .map((e) => _buildOrderItem(e))
                  .toList(),
            ),
            const Divider(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // finalize.create(null);
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
              pros.nameOf(product.variantId),
              // pros
              //     .singleWhere((element) => element.id == product.variantId)
              //     .name,
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
    for (var e in context.watch<InvoiceProvider>().activeInvoice!.items) {
      final price = double.tryParse(e.unitPrice) ?? 0.0;
      subtotal += price * e.quantity;
    }

    final double discountAmount = subtotal * (discountPercent / 100);
    final double taxedBase = subtotal - discountAmount;
    final double taxAmount = taxedBase * (taxPercent / 100);
    final double total = taxedBase + taxAmount;
    String fmt(double v) => v.toStringAsFixed(2);

    context.watch<InvoiceProvider>().activeInvoice!.subtotal = fmt(subtotal);
    context.watch<InvoiceProvider>().activeInvoice!.discount = fmt(
      discountAmount,
    );
    context.watch<InvoiceProvider>().activeInvoice!.tax = fmt(taxAmount);
    context.watch<InvoiceProvider>().activeInvoice!.total = fmt(total);
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
