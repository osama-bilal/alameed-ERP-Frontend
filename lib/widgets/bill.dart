// دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
// import 'package:ponit_of_sales/screens/selling.dart';

class OrderPanel extends StatelessWidget {
  final ScrollController controller;
  const OrderPanel({super.key, required this.controller});
  // @override
  // void initState() {
  // _saleInvoiceController = SaleInvoiceController(context: context);
  // _controller = widget.controller ?? ScrollController();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  // Only dispose the controller if it was created locally.
  // _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        if (state.loading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.activeInvoice == null) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Text("Create invoice First"),
          );
        }

        SaleInvoice invoice = state.activeInvoice!;
        // Provider.of<SellingProvider>(context).setActive(invoice);
        final item = state.activeInvoice!.items;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                Text(
                  'Order No: ${invoice.id}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                Wrap(
                  children: item
                      .map((e) => _buildOrderItem(e, context))
                      .toList(),
                ),
                const Divider(height: 20),
                _buildOrderSummary(invoice),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (item.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("اضف منتجات للفاتورة اولا"),
                                ),
                              );
                              return;
                            }
                            try {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          ctx.pop();
                                        },
                                        child: Text("cancle"),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          // ctx.pop();
                                          // setState(() {
                                          BlocProvider.of<PosBloc>(
                                            context,
                                          ).add(FinalizeActiveInvoice());
                                          // });
                                        },
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
  Widget _buildOrderItem(SaleItem product, BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: product.quantity.toString(),
    );

    void updateQuantity(int q) {
      if (q < 0) q = 0;
      // setState(() {
      product.quantity = q;
      BlocProvider.of<PosBloc>(
        context,
        listen: false,
      ).add(UpdateItem(product.id!, product));
      // });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // setState(() {
              BlocProvider.of<PosBloc>(
                context,
              ).add(RemoveItemFromActiveInvoice(product.id!));
              // });
            },
            icon: Icon(Icons.delete),
          ),
          Expanded(
            child: Text(
              context.watch<ProductsProvider>().nameOf(product.variantId),
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
                  // onChanged: (value) {
                  //   final current = int.tryParse(value);
                  //   if (current != null && current >= 0) {
                  //     updateQuantity(current);
                  //   }
                  // },
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

  Widget _buildOrderSummary(SaleInvoice invoice) {
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
