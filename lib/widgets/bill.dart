// دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/sell/sell_bloc.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/widgets/order_item.dart';

class OrderPanel extends StatelessWidget {
  final ScrollController controller;
  const OrderPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        if (state.loading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.activeInvoice == null) {
          return Card( 
            // alignment: Alignment.center,
            child: Text("Create invoice First", textAlign: TextAlign.center,),
          );
        }

        SaleInvoice invoice = state.activeInvoice!;
        final items = state.activeInvoice!.items;
        return Card(
          elevation: 2,
          margin: EdgeInsets.zero, // To fill the space if it's a direct child
          // padding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  Text(
                    '${invoice.exchangeWith != null ? "Replace " : ""}Order No: ${invoice.id}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20),
                  Wrap(
                    children: items
                        .map(
                          (e) => OrderItem(
                            onDelete: () {
                              BlocProvider.of<PosBloc>(
                                context,
                              ).add(RemoveItemFromActiveInvoice(e.id!));
                            },
                            product: e,
                            update: (item) => BlocProvider.of<PosBloc>(
                              context,
                              listen: false,
                            ).add(UpdateItem(item.id!, item)),
                          ),
                        )
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
                              if (items.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("اضف منتج واحد على الاقل"),
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
                                          child: const Text("cancle"),
                                        ),
            
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            BlocProvider.of<SellingBloc>(
                                              context,
                                            ).add(
                                              StartSell(invoiceSell: invoice),
                                            );
                                          },
                                          child: const Text("Continue"),
                                        ),
                                      ],
                                      title: const Text(
                                        "Are you sure! save the Bill?",
                                      ),
                                      content: const Text(
                                        "After continue you can't edit anything in the Bill.",
                                      ),
                                    );
                                  },
                                );
                              } catch (e) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("فشل العملية: $e")),
                                  );
                                });
                              }
                              // تنفيذ دفع/تلخيص
                            },
                            child: const Text("Checkout"),
                          ),
                        ),
                        SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            BlocProvider.of<PosBloc>(
                              context,
                            ).add(ClearActiveInvoice());
                            // مسح الفاتورة أو إجراءات أخرى
                          },
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // الدوال الفرعية الأخرى (تبقى كما هي)
  Widget _buildOrderSummary(SaleInvoice invoice) {
    double subtotal = 0;

    for (var e in invoice.items) {
      final price = double.tryParse(e.unitPrice) ?? 0.0;
      subtotal += price * e.quantity;
    }
    String fmt(double v) => v.toStringAsFixed(2);

    invoice.subtotal = fmt(subtotal);
    return Column(
      children: [
        _buildSummaryRow('Amount', "${fmt(subtotal)} SR", isTotal: true),
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
              fontSize: isTotal ? 16 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }
}
