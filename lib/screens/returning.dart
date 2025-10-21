import 'package:flutter/widgets.dart';
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
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}