// دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)
// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class OrderPanel extends StatefulWidget {
  const OrderPanel({super.key, this.controller});
  final ScrollController? controller;
  @override
  State<OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<OrderPanel> {
  late final ScrollController _controller;
  @override
  void initState() {
    _controller = widget.controller ?? ScrollController();
    super.initState();
  }

  late SaleInvoice invoice;
  @override
  void dispose() {
    // Only dispose the controller if it was created locally.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        if (state.activeInvoice == null) {
          return Center(child: Text("Select invoice First"));
        }
        invoice = state.activeInvoice!;
        final item = state.activeInvoice!.items;
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
                  'Order No: ${invoice.id}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                Wrap(children: item.map((e) => _buildOrderItem(e)).toList()),
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
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    actions: [
                                      TextButton(
                                        onPressed: () {},
                                        child: Text("cancle"),
                                      ),

                                      TextButton(
                                        onPressed: () {},
                                        child: Text("Continue"),
                                      ),
                                    ],
                                    title: Text("Are you sure! save the Bill?"),
                                    content: Text(
                                      "After continue you can't edit anything in the Bill.",
                                    ),
                                  );
                                },
                              );
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
        BlocProvider.of<PosBloc>(context).add(UpdateItem(product.id!, product));
        // this.updateQuantity(product, q);
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                BlocProvider.of<PosBloc>(
                  context,
                ).add(RemoveItemFromActiveInvoice(product.id!));
              });
            },
            icon: Icon(Icons.delete),
          ),
          Expanded(
            child: Text(
              // product.toString(),
              context.watch<ProductsProvider>().nameOf(product.variantId),
              // .singleWhere((element) => element.id == product.variantId)
              // .name,
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
    for (var e in invoice.items) {
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
