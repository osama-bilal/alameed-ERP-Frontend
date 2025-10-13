import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/screens/pos.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
  final TextEditingController _discount = TextEditingController();

  final double taxPercent = 0.0;

  double discount = 0.00;

  late final MainController<ViewParty> cusView;

  double discountPercent(double totals, double discount) =>
      discount / totals * 100;

  double taxAmount(double totals) => totals * (taxPercent / 100);

  double total(double totals) => totals + taxAmount(totals);

  String fmt(double v) => v.toStringAsFixed(2);

  ViewParty<Customer>? customer;

  final List<ViewParty<Customer>> parties = [];

  late final MainController<PaymentMethod> _paymethodController;

  final List<PaymentMethod> payMethods = [];

  PaymentMethod? selectedMethod;

  final _payAmount = TextEditingController(text: "0");
  double totals = 0.0;
  @override
  void initState() {
    cusView = MainController<ViewParty>(
      context: context,
      tempService: GeneralService<ViewParty<Customer>>(
        endpoint: "/parties/customers/",
        fromMap: ViewParty.fromMap,
        toMap: (o) => o.toMap(),
      ),
    );
    _paymethodController = MainController<PaymentMethod>(
      context: context,
    );
    _paymethodController.fethAll();
    cusView.fethAll();
    super.initState();
  }

  SaleInvoice? invoice;

  // set
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<PosBloc, PosState>(
        listener: (ctx, state) {
          if (state.loading) {
          } else if (state.sellInvoice != null &&
                  state.sellInvoice!.status != "final" ||
              state.sellInvoice == null) {
            BlocProvider.of<PosBloc>(context).add(Reset());

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PosScreen(key: UniqueKey()),
              ),
            );
          }
          if (state.sellInvoice != null) {
            invoice = state.sellInvoice;
            totals = state.sellInvoice!.totals;
          }
          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "فشل الاتصال بالسيرفر سيتم المحاولة\nError: ${state.error}",
                  ),
                ),
              );
            });
          }
        },
        builder: (ctx, state) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state.sellInvoice != null) {
            invoice = state.sellInvoice;
            totals = state.sellInvoice!.totals;
            _discount.text = discount.toString();
          }
          return SingleChildScrollView(
            child: RefreshIndicator(
              onRefresh: () async {},
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
                            controller: _discount,
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
                            onSubmitted: (v) {
                              setState(() {
                                _discount.text = v;
                                discount = double.tryParse(v) ?? discount;
                              });
                            },
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
                                        // TODO: show create customer dialog
                                      },
                                      label: "Not exist",
                                    )
                                  : Text(customer.toString()),
                            ],
                          ),
                        ),
                        BlocBuilder<GeneralBloc<ViewParty>, GeneralState>(
                          builder: (ctx3, customerState) {
                            if (customerState
                                is GeneralLoadInProgress<ViewParty>) {
                              return Center(child: CircularProgressIndicator());
                            } else if (customerState
                                is ItemLoadFailure<ViewParty>) {
                              return Text(
                                "حصل خطاء عند جلب العملاء من السيرفر",
                              );
                            }
                            if (customerState is ItemsLoadSuccess<ViewParty>) {
                              parties.clear();
                              parties.addAll(
                                customerState.items
                                    as Iterable<ViewParty<Customer>>,
                              );
                            }
                            return MySearchAnchor<ViewParty>(
                              searchIn: parties,
                              onSubmitted: (p) {
                                setState(() {
                                  // try {
                                  customer = parties.singleWhere(
                                    (element) => element.toString() == p,
                                    orElse: customer != null
                                        ? () {
                                            return customer!;
                                          }
                                        : null,
                                  );
                                  // _state.setCustomer(customer!.id);
                                  // } on Exception {
                                  //
                                  // }
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(),
                    Column(
                      children: [
                        Text("Select Payment Method"),
                        Divider(),
                        BlocBuilder<GeneralBloc<PaymentMethod>, GeneralState>(
                          builder: (ctx2, paystate) {
                            if (paystate
                                is GeneralLoadInProgress<PaymentMethod>) {
                              return Center(child: CircularProgressIndicator());
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
                                setState(() {
                                  if (value != null) {
                                    selectedMethod = value;

                                    // _state.setPayMethod(value.id);
                                  }
                                });
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

                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: "The Paid Amount",
                      ),

                      enabled: selectedMethod != null,
                      onChanged: (value) => _payAmount.text = value,
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
                    Divider(),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (customer == null &&
                                double.parse(_payAmount.text) <
                                    total(totals - discount)) {
                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "The Paid must be equal or greater than total",
                                  ),
                                ),
                              );
                              // });
                              return;
                            }
                            // var newSell = invoi;
                            if (invoice != null) {
                              invoice!.discount = _discount.text;
                              invoice!.customerId = customer?.id;
                              invoice!.tax = fmt(taxAmount(totals - discount));
                              invoice!.paid = _payAmount.text;
                              BlocProvider.of<PosBloc>(
                                context,
                                listen: false,
                              ).add(
                                SaveAnd(
                                  thenGo: PaySellInvoice(
                                    amount: _payAmount.text,
                                  ),
                                  invoice: invoice!,
                                ),
                                // UpdateSellInvoice(
                                //   id: invoice!.id!,
                                //   invoice: invoice!,
                                // ),
                              );
                            }
                          },
                          child: Text("Save & Print"),
                        ),
                        SizedBox(width: 10),
                        if (customer != null)
                          ElevatedButton(
                            onPressed: () {
                              invoice!.discount = _discount.text;
                              invoice!.customerId = customer?.id;
                              invoice!.tax = fmt(taxAmount(totals - discount));
                              BlocProvider.of<PosBloc>(
                                context,
                                listen: false,
                              ).add(
                                SaveAnd(
                                  thenGo: SetUnpaidSell(),
                                  invoice: invoice!,
                                ),
                                // UpdateSellInvoice(
                                //   id: invoice!.id!,
                                //   invoice: invoice!,
                                // ),
                              );
                              // BlocProvider.of<PosBloc>(
                              //   context,
                              //   listen: false,
                              // ).add(SetUnpaidSell());
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
    );
  }
}
