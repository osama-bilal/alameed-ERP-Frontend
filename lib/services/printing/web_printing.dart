// import 'dart:typed_data';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/sell/sell_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/services/printing/generate_web_pdf.dart';
import 'package:printing/printing.dart';

class ThermalPrinting extends StatefulWidget {
  const ThermalPrinting({
    super.key,
    required this.invoice,
    required this.customer,
  });

  final SaleInvoice invoice;
  final String customer;

  @override
  State<ThermalPrinting> createState() => _ThermalPrintingState();
}

class _ThermalPrintingState extends State<ThermalPrinting> {
  @override
  void initState() {
    super.initState();
  }

  bool goin = false;
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _printPdf() async {
    if (mounted) {
      setState(() {
        goin = true;
      });
    }
    Uint8List pdfBytes = await generateReceipt(
      invoice: widget.invoice,
      products: context.read<ProductsProvider>().pros,
      customer: widget.customer,
    );
    debugPrint(pdfBytes.length.toString());
    try {
      if (await Printing.layoutPdf(onLayout: (format) async => pdfBytes)) {
        log("print started");
      } else {
        log('print faild');
      }
    } on Exception catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) {
      setState(() {
        goin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (goin) {
      return Center(child: CircularProgressIndicator());
    }
    // Display a loading indicator while the PDF is being prepared and the print dialog is opening.
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.invoice.toString()),
            Divider(height: 10),
            ElevatedButton(onPressed: _printPdf, child: const Text("Print")),
            Divider(height: 10),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<SellingBloc>(context).add(PrintFinished());
                Navigator.pop(context);
              },
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
