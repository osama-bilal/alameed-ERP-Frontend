// دالة بناء لوحة الطلب (تم تعديلها لتكون ديناميكية)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';
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

  void updateQuantity(int q) {
    if (q < 0) q = 0;
    if ((limit ?? q) >= q) {
      product.quantity = q;
      update(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: product.quantity.toString(),
    );
    return GestureDetector(
      onTap: () {
        final priceController = TextEditingController(
          text: product.unitPrice.toString(),
        );
        final noteController = TextEditingController(text: product.notes ?? '');
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Edit Item"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecimalField(controller: priceController, hint: "Unit Price"),
                  SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Add a note to the item",
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    product.unitPrice = priceController.text;
                    product.notes = noteController.text;
                    update(product);
                    Navigator.of(ctx).pop();
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Row(
          children: [
            IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.read<ProductsProvider>().nameOf(product.variantId),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (product.notes != null && product.notes!.isNotEmpty)
                    Text(
                      product.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final current = int.tryParse(controller.text);
                    if (current != null && current > 1) {
                      updateQuantity(current - 1);
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final current = int.tryParse(value);
                      if (current != null) {
                        updateQuantity(current);
                      }
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
                    final current = int.tryParse(controller.text);
                    if (current != null) {
                      updateQuantity(current + 1);
                    }
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
      ),
    );
  }
}
