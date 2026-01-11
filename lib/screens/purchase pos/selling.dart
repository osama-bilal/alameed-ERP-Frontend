import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/blocs/pos%20purch/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/pos%20purch/sell/sell_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/screens/purchase%20pos/pos.dart';
import 'package:ponit_of_sales/services/printing/generate_pdf.dart';

import 'package:ponit_of_sales/services/printing/thermal_printer.dart'
    if (dart.library.html) 'package:ponit_of_sales/services/printing/web_printing.dart';

import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/supplier.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:provider/provider.dart';

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
  late final PurchBloc sell;

  @override
  void initState() {
    sell = context.read<PurchBloc>();
    _pro = Provider.of<ProductsProvider>(context, listen: false);
    _paymethodController = MainController<PaymentMethod>(context: context);
    _paymethodController.fetchAll();
    super.initState();
    parties = context.read<AppParties>().suppliers;
  }

  late final l10n = AppLocalizations.of(context)!;
  void cancelInvoice() {
    if (invoice == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.areYouSureCancleTheInvoice),
          actions: [
            ElevatedButton(onPressed: () => ctx.pop(), child: Text(l10n.no)),
            ElevatedButton(
              onPressed: () {
                sell.add(ConfirmSell(invoice: invoice!, action: 'cancel'));
              },
              child: Text(l10n.makeCancelled),
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

  PurchaseInvoice? invoice;
  Future<void> saveAsPdf(PurchaseInvoice invoice) async {
    try {
      Uint8List pdf;
      if (true) {
        pdf = await generateInvoicePdf(
          invoice: invoice,
          products: _pro.pros,
          customer: customer?.name ?? "",
          l10n: l10n,
        );
      }
      String? outputPath = await FilePicker.platform
          .saveFile(
            dialogTitle: l10n.chooseInvoiceSaveLocation,
            fileName: 'invoice${invoice.id}.pdf',
            allowedExtensions: ['pdf'],
            type: FileType.custom,
            bytes: pdf,
          )
          .then((value) {
            if (value != null || kIsWeb) {
              BlocProvider.of<PosPurchBloc>(
                context,
                listen: false,
              ).add(Reset());
              BlocProvider.of<PurchBloc>(
                context,
                listen: false,
              ).add(PrintFinished());
            }
            return value;
          });
      if (outputPath == null && !kIsWeb) {
        log(l10n.saveAsPdfCancelled);
        return;
      }
      log('File saved to: $outputPath');
    } catch (e, s) {
      log(l10n.errorSavingPdf(e.toString()), stackTrace: s);
    }
  }

  final payBusttonState = WidgetStatesController({WidgetState.disabled});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    _payAmount.addListener(() {
      if (mounted) {
        setState(() {
          if (canPay) {
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
        body: BlocConsumer<PurchBloc, PurchState>(
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
              Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => PosPurchScreen()));
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
                      title: Text(l10n.selectAction),
                      content: Text(l10n.choseOneOfThoseActionsToDoOrExit),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            await saveAsPdf(state.invoice);
                          },
                          child: Text(l10n.saveAsPDF),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ThermalPrinting(
                                          key: UniqueKey(),
                                          customer: customer?.name ?? "",
                                          invoice: state.invoice,
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
                          child: Text(l10n.print),
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
                          Text("${l10n.subtotal}:"),
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
                                Text("${l10n.discount}:"),
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
                          Text("${l10n.tax}:"),
                          Text(fmt(taxAmount(totals - discount))),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${l10n.total}:"),
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
                                Text("${l10n.customer}:"),
                                customer == null
                                    ? CreateNewButton(
                                        onPressed: () {
                                          showEditSupplierDialog(
                                            context,
                                            Supplier(
                                              name: "",
                                              phone: "",
                                              address: "",
                                            ),
                                          );
                                        },
                                        label: "${l10n.notExist}!",
                                      )
                                    : Text(customer.toString()),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) => MySearchAnchor<ViewParty>(
                              onRefresh: () =>
                                  context.read<AppParties>().fetchSuppliers(),
                              searchIn: parties.toList(),
                              onSubmitted: (p) {
                                if (mounted && p.isNotEmpty) {
                                  setState(() {
                                    customer = p.first;
                                    isPartial = false;
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
                          Text("${l10n.selectPaymentMethod}:"),
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
                                return Text(l10n.failedToLoadPaymentMethods);
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
                                hintText: l10n.thePaidAmount,
                              ),
                              enabled: selectedMethod != null,
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
                                                l10n.theRemainingWillBeAddedAsADebtOnTheCustomer,
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
                              Text("${l10n.partial}!"),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: l10n.addNotesToTheInvoice,
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
                                            l10n.thePaidMustBeEqualOrGreaterThanTotal,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (invoice != null) {
                                      invoice!.discount = discount.toString();
                                      invoice!.supplierId = customer?.id;
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
                            child: Text(l10n.savePrint),
                          ),
                          SizedBox(width: 10),
                          if (customer != null)
                            ElevatedButton(
                              onPressed: () {
                                invoice!.discount = discount.toString();
                                invoice!.supplierId = customer?.id;
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
                              child: Text(l10n.addToDebit),
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
