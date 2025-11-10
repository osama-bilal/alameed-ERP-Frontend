import 'dart:developer';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/sell/sell_bloc.dart';
// import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/services/printing/generate_pdf.dart';

import 'package:ponit_of_sales/services/printing/thermal_printer.dart'
    if (dart.library.html) 'package:ponit_of_sales/services/printing/web_printing.dart';

import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/customers.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:provider/provider.dart';

//  import '../services/printing/generate_web_pdf.dart';
/*
this screen must display the totals of the invoice and selctiong the customer and  the payment Method and the amount of paid 
and the notes of the invoice also there are some constraints like if it pay less then total and print the invoice button  
*/
class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final double taxPercent = 0.0;

  double discount = 0.00;

  double discountPercent(double totals, double discount) =>
      discount / totals * 100;

  double taxAmount(double totals) => totals * (taxPercent / 100);

  double total(double totals) => totals + taxAmount(totals);

  String fmt(double v) => v.toStringAsFixed(2);

  ViewParty? customer;

  late final Set<ViewParty> parties;

  late final MainController<PaymentMethod> _paymethodController;
  final Set<PaymentMethod> payMethods = {};

  PaymentMethod? selectedMethod;
  final _notesController = TextEditingController();

  bool get canPay {
    final paid = (double.tryParse(_payAmount.value.text) ?? 0);
    return (paid > 0 && isPartial) || paid >= total(totals - discount);
  }

  final _payAmount = TextEditingController(text: "0");
  double totals = 0.0;
  late final ProductsProvider _pro;
  bool isPartial = false;
  late final SellingBloc sell;

  @override
  void initState() {
    sell = context.read<SellingBloc>();
    _pro = Provider.of<ProductsProvider>(context, listen: false);
    _paymethodController = MainController<PaymentMethod>(context: context);
    _paymethodController.fetchAll();
    super.initState();
    parties = context.read<AppParties>().customers;
  }

  void cancelInvoice() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Are you sure Cancle the invoice"),
          actions: [
            ElevatedButton(onPressed: () => ctx.pop(), child: Text("No")),
            ElevatedButton(
              onPressed: () {
                sell.add(ConfirmSell(invoice: invoice!, action: 'cancel'));
              },
              child: Text("Make cancellled"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _payAmount.dispose();
    _notesController.dispose();
    super.dispose();
  }

  SaleInvoice? invoice;
  Future<void> saveAsPdf(SaleInvoice invoice) async {
    final fontData = await rootBundle.load('assets/fonts/notosansarabic.ttf');
    final imageData = await rootBundle.load('assets/logo/logo.png');
    try {
      Uint8List pdf;
      if (kIsWeb) {
        pdf = await generateInvoicePdf(
          invoice: invoice,
          products: _pro.pros,
          customer: customer?.name ?? "",
          fontData: fontData.buffer.asUint8List(),
          imageData: imageData.buffer.asUint8List(),
        );
      } else {
        final receivePort = ReceivePort();

        // Load assets in the main isolate
        final payload = PdfGenPayload(
          sendPort: receivePort.sendPort,
          invoice: invoice,
          products: _pro.pros,
          customer: customer?.name ?? "",
          fontData: fontData.buffer.asUint8List(),
          imageData: imageData.buffer.asUint8List(),
        );
        await Isolate.spawn(generateInvoicePdfIsolate, payload);
        pdf = await receivePort.first as Uint8List;
      }

      String? outputPath = await FilePicker.platform
          .saveFile(
            dialogTitle: 'اختر مكان حفظ الفاتورة',
            fileName: 'invoice${invoice.id}.pdf',
            allowedExtensions: ['pdf'],
            type: FileType.custom,
            bytes: pdf,
          )
          .then((value) {
            if (value != null || kIsWeb) {
              BlocProvider.of<PosBloc>(context, listen: false).add(Reset());
              BlocProvider.of<SellingBloc>(
                context,
                listen: false,
              ).add(PrintFinished());
            }
            return value;
          });
      if (outputPath == null && !kIsWeb) {
        // User cancelled the picker
        log('Save as PDF cancelled by user.');
        return;
      }

      log('File saved to: $outputPath');
    } catch (e, s) {
      log('Error saving PDF: $e', stackTrace: s);
    }
  }

  final payBusttonState = WidgetStatesController({WidgetState.disabled});

  // set
  @override
  Widget build(BuildContext context) {
    // payBusttonState.
    _payAmount.addListener(() {
      if (mounted) {
        setState(() {
          if (double.parse(_payAmount.value.text) >= total(totals - discount)) {
            payBusttonState.update(WidgetState.disabled, false);
          } else {
            payBusttonState.update(WidgetState.disabled, true);
          }
        });
      }
    });
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        cancelInvoice();
      },
      child: Scaffold(
        appBar: AppBar(leading: CloseButton(onPressed: cancelInvoice)),

        body: BlocConsumer<SellingBloc, SellingState>(
          listener: (ctx, state) {
            if (state.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("${state.error}")));
              });
              return;
            }
            if (state is SellFinished) {
              context.pushReplacement('/pos');
              return;
            } else if (state is PrintInvoice) {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) {
                    return AlertDialog(
                      icon: CloseButton(
                        onPressed: () {
                          sell.add(PrintFinished());
                        },
                      ),
                      title: Text("Select Action"),
                      content: Text("Chose one of those actions to do or exit"),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            await saveAsPdf(state.invoice);
                          },
                          child: Text("Save as pdf"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // 1. First, pop the dialog. Use the dialog's context `ctx`.
                            // Navigator.of(ctx).pop();

                            // 2. Then, push the replacement screen. Use the screen's main context.
                            // No need for addPostFrameCallback here as we are in an event handler.
                            await Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ThermalPrinting(
                                          key: UniqueKey(),
                                          customer: customer?.name ?? "",
                                          invoice: state.invoice,
                                          products: _pro.pros,
                                        ),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      // Example: Scale transition
                                      return ScaleTransition(
                                        scale:
                                            Tween<double>(
                                              begin: 0.0,
                                              end: 1.0,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.fastOutSlowIn,
                                              ),
                                            ),
                                        child: child,
                                      );
                                    },
                                transitionDuration: Duration(milliseconds: 500),
                              ),
                            ).then((value) {
                              sell.add(PrintFinished());
                            });
                          },
                          child: Text("Print"),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          },
          buildWhen: (previous, current) => previous != current,
          builder: (ctx, state) {
            if (state is SellingStarted || state is SellUpdated) {
              invoice = state is SellUpdated
                  ? state.invoice
                  : state is SellingStarted
                  ? state.invoice
                  : invoice;
            } else if (state is Loading || invoice == null) {
              return Center(child: CircularProgressIndicator());
            }
            totals = invoice!.totals;

            return RefreshIndicator(
              onRefresh: () async {
                if (invoice == null) {
                  return;
                }
                _paymethodController.fetchAll();
                sell.add(RefreshInvoice(id: invoice!.id!));
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sub total:"),
                          Text(totals.toStringAsFixed(2)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Discount:"),
                                Text(
                                  "%${fmt(discountPercent(totals, discount))}",
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              decoration: InputDecoration(),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(
                                    r'^\d*\.?\d{0,2}',
                                  ), // allows decimals with up to 2 digits after dot
                                ),
                              ],
                              onChanged: (value) => setState(() {
                                discount = double.tryParse(value) ?? discount;
                              }),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tax:"),
                          Text(fmt(taxAmount(totals - discount))),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total:"),
                          Text(fmt(total(totals - discount))),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("for Customer:"),
                                customer == null
                                    ? CreateNewButton(
                                        onPressed: () {
                                          showEditCustomerDialog(
                                            context,
                                            Customer(name: "", phone: ""),
                                          );
                                        },
                                        label: "Not exist!",
                                      )
                                    : Text(customer.toString()),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) =>
                                MySearchAnchor<ViewParty>(
                                  searchIn: parties.toList(),
                                  onSubmitted: (p) {
                                    if (mounted) {
                                      setState(() {
                                        customer = p;
                                      });
                                    }
                                  },
                                ),
                          ),
                        ],
                      ),
                      Divider(),
                      Column(
                        children: [
                          Text("Select Payment Method"),
                          Divider(),
                          BlocBuilder<GeneralBloc<PaymentMethod>, GeneralState>(
                            buildWhen: (previous, current) =>
                                previous
                                    is GeneralLoadInProgress<PaymentMethod> &&
                                current != previous,
                            builder: (ctx2, paystate) {
                              if (paystate
                                  is GeneralLoadInProgress<PaymentMethod>) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (paystate
                                  is ItemLoadFailure<PaymentMethod>) {
                                return Text("Filed to load");
                              } else if (paystate
                                  is ItemsLoadSuccess<PaymentMethod>) {
                                payMethods.clear();
                                payMethods.addAll(paystate.items);
                              }
                              return RadioGroup(
                                onChanged: (value) {
                                  if (value != null && mounted) {
                                    setState(() {
                                      selectedMethod = value;
                                    });
                                  }
                                },
                                groupValue: selectedMethod,
                                child: Column(
                                  children: [
                                    for (var method in payMethods)
                                      RadioListTile(
                                        value: method,
                                        title: Text(method.methodName),
                                        selectedTileColor: Colors.blue,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Divider(),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _payAmount,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: "The Paid Amount",
                              ),
                              enabled: selectedMethod != null,
                              // onChanged: (value) => _payAmount.text = value,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(
                                    r'^\d*\.?\d{0,2}',
                                  ), // allows decimals with up to 2 digits after dot
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              Checkbox(
                                value: isPartial,
                                onChanged: customer == null
                                    ? null
                                    : (value) {
                                        if (!isPartial) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "The remaining will be added as a debt on the customer",
                                              ),
                                            ),
                                          );
                                        }
                                        setState(() {
                                          if (value != null) {
                                            isPartial = value;
                                          }
                                        });
                                      },
                              ),
                              Text("Partial?"),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Add notes to the invoice",
                        ),
                        maxLines: 3,
                      ),
                      const Divider(),
                      Row(
                        children: [
                          ElevatedButton(
                            statesController: payBusttonState,
                            onPressed:
                                payBusttonState.value.contains(
                                  WidgetState.disabled,
                                )
                                ? null
                                : () {
                                    if (customer == null &&
                                        double.parse(_payAmount.text) <
                                            total(totals - discount)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "The Paid must be equal or greater than total",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (invoice != null) {
                                      invoice!.discount = discount.toString();
                                      invoice!.customerId = customer?.id;
                                      invoice!.tax = fmt(
                                        taxAmount(totals - discount),
                                      );
                                      invoice!.paid = _payAmount.text;
                                      invoice!.paymentMethodId =
                                          selectedMethod?.id;
                                      invoice!.notes = _notesController.text;
                                      sell.add(
                                        ConfirmSell(
                                          action: 'pay',
                                          invoice: invoice,
                                        ),
                                      );
                                    }
                                  },
                            child: Text("Save & Print"),
                          ),
                          SizedBox(width: 10),
                          if (customer != null)
                            ElevatedButton(
                              onPressed: () {
                                invoice!.discount = discount.toString();
                                invoice!.customerId = customer?.id;
                                invoice!.tax = fmt(
                                  taxAmount(totals - discount),
                                );
                                invoice!.notes = _notesController.text;
                                sell.add(
                                  ConfirmSell(
                                    action: 'unpaid',
                                    invoice: invoice,
                                  ),
                                );
                              },
                              child: Text("Add to debit"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
