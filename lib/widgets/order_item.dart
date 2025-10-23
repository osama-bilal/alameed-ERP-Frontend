// دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class OrderItem extends StatelessWidget {
  const OrderItem({
    super.key,
    required this.product,
    required this.update,
    required this.onDelete,
    this.limit,
  });
  final int? limit;
  final SaleItem product;
  final void Function() onDelete;
  final void Function(SaleItem item) update;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: product.quantity.toString(),
    );
    void updateQuantity(int q) {
      if (q < 0 && (limit ?? q) >= q) q = 0;
      product.quantity = q;
      update(product);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
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
                width: 50,
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
}
