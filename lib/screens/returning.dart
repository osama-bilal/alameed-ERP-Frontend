import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final pros = context.watch<ProductsProvider>();
    invoice = provide.invoice;
    // if (invoice == null) {
    // return ;
    // }

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
                  child: OrderItem(
                    // limit: provide.itemOf(e)!.quantity,
                    onDelete: () => provide.removeReturn(e.saleItemId),
                    product: provide.itemOf(e)!,
                    update: (item) => provide.updateReturn(
                      ReturnSaleProvider(
                        saleItemId: item.id!,
                        quantity: item.quantity,
                        // returnType: "return",
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
    var itemsGrid = GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: invoice?.items.length,
      itemBuilder: (context, index) {
        if (invoice == null) {
          return null;
        }
        final item = invoice!.items[index];
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
              ReturnSaleProvider(
                saleItemId: item.id ?? 0,
                quantity: 1,
                // returnType: "return",
              ),
            );
          },
          product: prod,
        );
      },
    );
    Widget body = Column(
      children: [
        Text("Chose Item to return"),
        Row(
          children: [
            Expanded(child: itemsGrid),
            Expanded(
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
      ],
    );
    if (isMobile) {
      //itemsGrid = NeverScrollableScrollPhysics();
      body = Stack(
        fit: StackFit.expand,
        children: [
          Column(children: [Text("Chose Item to return"), itemsGrid]),
          Positioned(
            child: DraggableScrollableSheet(
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: column,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<ReturnBloc, ReturnState>(
        listener: (context, state) {
          if (state is ReturnFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            });
          } else if (state is ReplaceStarted) {
            // GOTO Replace Screen
          } else if (state is ReturnFinished) {
            Navigator.pop(context);
          } else if (state is ReturnSuccess) {
            // GOTO Pay Screen
          } else if (state is ReturnStarted) {
            setState(() {
              provide.setInvoice(state.invoice);
            });
          }
        },
        child: invoice == null
            ? Center(child: CircularProgressIndicator())
            : Padding(padding: EdgeInsetsGeometry.all(16), child: body),
        // },
      ),
    );
  }
}
