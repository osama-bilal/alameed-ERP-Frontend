import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/pos%20purch/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/pos%20purch/return/return_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/return%20copy.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import '../../l10n/app_localizations.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/controllers/provider/return.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'order_item.dart';
import 'package:ponit_of_sales/widgets/product_card.dart';
import 'package:provider/provider.dart';

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
class ReturnPurchScreen extends StatefulWidget {
  const ReturnPurchScreen({super.key, required this.invCode});
  final String invCode;

  @override
  State<ReturnPurchScreen> createState() => _ReturnPurchScreenState();
}

class _ReturnPurchScreenState extends State<ReturnPurchScreen> {
  PurchaseInvoice? invoice;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ReturnPurchBloc>(
      context,
    ).add(StartReturn(returnCode: widget.invCode));
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width <= 700;
    final provide = context.watch<ReturnPurchProvider>();
    final pros = context.read<ProductsProvider>();
    invoice = provide.invoice;
    final l10n = AppLocalizations.of(context)!;

    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.invoiceNumber(invoice?.id ?? '')),
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
                        return SizedBox(height: 0, width: 0);
                      }
                      return OrderItem(
                        limit: originalItem.quantity,
                        onDelete: () => provide.removeReturn(e),
                        product: PurchaseItem(
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
                          final returnProviderItem = ReturnPurchaseProvider(
                            saleItemId: item.id!,
                            quantity: item.quantity,
                          );
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
                          (e) => ReturnPurchase(
                            purchaseItemId: e.saleItemId,
                            quantity: e.quantity,
                            returnType: 'refund',
                          ),
                        )
                        .toList();
                    context.read<ReturnPurchBloc>().add(
                      ReturnMoney(items: itemsToReturn),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(l10n.returnMoney),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (invoice == null) return;
                    final itemsToReturn = provide.items
                        .map(
                          (e) => ReturnPurchase(
                            purchaseItemId: e.saleItemId,
                            quantity: e.quantity,
                            returnType: 'exchange',
                          ),
                        )
                        .toList();
                    context.read<ReturnPurchBloc>().add(
                      StartReplace(
                        itemsReturned: itemsToReturn,
                        oldInvoice: invoice!,
                      ),
                    );
                  },
                  child: Text(l10n.replace),
                ),
              ),
            ],
          ),
      ],
    );
    final sales = invoice == null ? <PurchaseItem>[] : invoice!.items;
    var itemsGrid = sales.isEmpty
        ? Center(child: Text(l10n.invoiceNotFound))
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
                  name: l10n.unknown,
                  barcode: l10n.unknown,
                  price: item.unitPrice,
                  cost: "0.0",
                  quantity: item.quantity,
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
                quantity: item.quantity,
                brand: product.brand,
                category: product.category,
              );
              return ProductCard(
                onTap: () {
                  provide.addReturn(
                    ReturnPurchaseProvider(
                      saleItemId: item.id ?? 0,
                      quantity: 1,
                    ),
                  );
                },
                product: prod,
              );
            },
          );
    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseItemToReturn,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                  Text(
                    l10n.chooseItemToReturn,
                    style: const TextStyle(
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
        title: Text(l10n.returnForInvoice(invoice?.id ?? '')),
        leading: BackButton(
          onPressed: () {
            context.read<ReturnProvider>().clear();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocListener<ReturnPurchBloc, ReturnPurchState>(
        listener: (context, state) {
          if (state is ReturnFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            });
          } else if (state is ReplaceStarted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.replaceStarted(state.invoice.id.toString())),
              ),
            );
            context.read<PosPurchBloc>().state.invoices.add(state.invoice);
            context.read<PosPurchBloc>().add(SetActiveInvoice(state.invoice));
            context.read<ReturnProvider>().clear();
            Navigator.pop(context); // Or push to POS screen
          } else if (state is ReturnFinished) {
            context.read<ReturnProvider>().clear();
            Navigator.pop(context);
          } else if (state is ReturnSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.returnSuccess)));
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

  Widget _buildReturnSummary(ReturnPurchProvider provider) {
    final double total = provider.total;
    String fmt(double v) => v.toStringAsFixed(2);

    return Column(
      children: [
        _buildSummaryRow(
          AppLocalizations.of(context)!.totalReturnAmount,
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
