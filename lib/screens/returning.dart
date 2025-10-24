import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/return/return_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/controllers/provider/return.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/widgets/order_item.dart';
import 'package:ponit_of_sales/widgets/product_card.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

/*
اولا نبدا عندما تبدا عملية الارجاع نجلب اسم المتغيرات من patries/product-variants/ and store them in SyaytemParties provider
then show the list of sale Items of the invoice by them informations -focus on the quantity must be equal (quantity - returnedQuantity)
the the user select the items wich he want then press one of the butons option Replace or Return all of them we will save the returns 
if the pressed button is replace button then make the screen like POS screen or jump to it or anything 
the important thing is we need to save the total price of return and create a new invoice make it related to the return Invoice by "relatedInvoiceId"
then when complete we can go to the pay page or Selling(page) we can add the the total of return as a discount to the new invoice, 
 if the pressed button is return goto pay page directlly but without a new invoice to pay
 i need to save the return item as sale item for the view and as ReturnSales for the return process 
 */
class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key, required this.invCode});
  final String invCode;

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  SaleInvoice? invoice;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ReturnBloc>(
      context,
    ).add(StartReturn(returnCode: widget.invCode));
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    final provide = context.watch<ReturnProvider>();
    final pros = context.read<ProductsProvider>();
    invoice = provide.invoice;

    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Invoice Number: ${invoice?.id}"),
        Divider(),
        Wrap(
          children: provide.items
              .map(
                (e) => ChangeNotifierProvider.value(
                  value: e,
                  child: Builder(
                    builder: (context) {
                      final originalItem = provide.itemOf(e);
                      if (originalItem == null) {
                        // This can happen if the invoice data is not fully loaded yet
                        // or if there's an inconsistency.
                        return SizedBox.shrink();
                      }
                      return OrderItem(
                        limit:
                            originalItem.quantity -
                            originalItem.returnedQuantity,
                        onDelete: () => provide.removeReturn(e.saleItemId),
                        product: SaleItem(
                          id: originalItem.id,
                          variantId: originalItem.variantId,
                          unitPrice: () {
                            final originalSubtotal =
                                double.tryParse(invoice?.subtotal ?? '0.0') ??
                                0.0;
                            final originalDiscount =
                                double.tryParse(invoice?.discount ?? '0.0') ??
                                0.0;
                            final itemPrice =
                                double.tryParse(originalItem.unitPrice) ?? 0.0;
                            return (itemPrice *
                                    (1 -
                                        (originalSubtotal > 0
                                            ? originalDiscount /
                                                  originalSubtotal
                                            : 0)))
                                .toStringAsFixed(2);
                          }(),
                          invoiceId: originalItem.invoiceId,
                          quantity: context
                              .watch<ReturnSaleProvider>()
                              .quantity,
                        ),
                        update: (item) {
                          final returnProviderItem = ReturnSaleProvider(
                            saleItemId: item.id!,
                            quantity: item.quantity,
                          );
                          // Update the quantity in the provider
                          // context
                          //     .read<ReturnSaleProvider>()
                          //     .updateQuantity(item.quantity);
                          // Notify the parent provider to update the list if needed for totals
                          provide.updateReturn(returnProviderItem);
                        },
                      );
                    },
                  ),
                ),
              )
              .toList(),
        ),
        const Divider(height: 20),
        _buildReturnSummary(provide),
        const SizedBox(height: 20),
        if (provide.items.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final itemsToReturn = provide.items
                        .map(
                          (e) => ReturnSale(
                            saleItemId: e.saleItemId,
                            quantity: e.quantity,
                            returnType: 'refund',
                          ),
                        )
                        .toList();
                    context.read<ReturnBloc>().add(
                      ReturnMoney(items: itemsToReturn),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Return Money"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (invoice == null) return;
                    final itemsToReturn = provide.items
                        .map(
                          (e) => ReturnSale(
                            saleItemId: e.saleItemId,
                            quantity: e.quantity,
                            returnType: 'exchange',
                          ),
                        )
                        .toList();
                    context.read<ReturnBloc>().add(
                      StartReplace(
                        itemsReturned: itemsToReturn,
                        oldInvoice: invoice!,
                      ),
                    );
                  },
                  child: const Text("Replace"),
                ),
              ),
            ],
          ),
      ],
    );
    final sales = invoice == null
        ? <SaleItem>[]
        : invoice!.items
              .where(
                (element) => element.quantity - element.returnedQuantity > 0,
              )
              .toList();
    var itemsGrid = sales.isEmpty
        ? Center(child: Text("Invoice not found or has no items."))
        : GridView.builder(
            shrinkWrap: true,
            physics: isMobile ? const NeverScrollableScrollPhysics() : null,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final item = sales[index];
              final product = pros.pros.firstWhere(
                (element) => item.variantId == element.id,
                orElse: () => POSView(
                  id: item.variantId,
                  name: "Unknown",
                  barcode: "Unknown",
                  price: item.unitPrice,
                  cost: "0.0",
                  quantity: item.quantity - item.returnedQuantity,
                  brand: "",
                  category: "",
                ),
              );
              final prod = POSView(
                id: item.variantId,
                name: product.name,
                barcode: product.barcode,
                price: item.unitPrice,
                cost: product.cost,
                quantity: item.quantity - item.returnedQuantity,
                brand: product.brand,
                category: product.category,
              );
              return ProductCard(
                onTap: () {
                  provide.addReturn(
                    ReturnSaleProvider(saleItemId: item.id ?? 0, quantity: 1),
                  );
                },
                product: prod,
              );
            },
          );
    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose Item to return",
          style: TextStyle(
            // fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: itemsGrid),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(child: column),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (isMobile) {
      body = Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 150,
              ), // Space for the sheet
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choose Item to return",
                    style: TextStyle(
                      // fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  itemsGrid,
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: column,
                ),
              );
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Return for Invoice #${invoice?.id}"),
        leading: BackButton(
          onPressed: () {
            context.read<ReturnProvider>().clear();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocListener<ReturnBloc, ReturnState>(
        listener: (context, state) {
          if (state is ReturnFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            });
          } else if (state is ReplaceStarted) {
            // TODO: GOTO Replace Screen (e.g., POS screen with initial discount)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Replace started for new invoice #${state.invoice.id}",
                ),
              ),
            );
            context.read<PosBloc>().state.invoices.add(state.invoice);
            context.read<PosBloc>().add(SetActiveInvoice(state.invoice));
            context.read<ReturnProvider>().clear();
            Navigator.pop(context); // Or push to POS screen
          } else if (state is ReturnFinished) {
            context.read<ReturnProvider>().clear();
            Navigator.pop(context);
          } else if (state is ReturnSuccess) {
            // TODO: GOTO Pay Screen or just show success and pop
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Return processed successfully!")),
            );
            context.read<ReturnProvider>().clear();
            Navigator.pop(context);
          } else if (state is ReturnStarted) {
            setState(() {
              provide.setInvoice(state.invoice);
            });
          }
        },
        child: invoice == null
            ? Center(child: CircularProgressIndicator())
            : Padding(padding: EdgeInsets.all(16), child: body),
      ),
    );
  }

  Widget _buildReturnSummary(ReturnProvider provider) {
    final double total = provider.total;
    String fmt(double v) => v.toStringAsFixed(2);

    return Column(
      children: [
        _buildSummaryRow(
          'Total Return Amount',
          '\$${fmt(total)}',
          isTotal: true,
        ),
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
              fontSize: isTotal ? 18 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : null,
              color: isTotal ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
