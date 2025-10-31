import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/models/payment_method.dart';

void showEditDebtPaymentDialog(BuildContext context, DebtPayment payment) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditDebtPaymentDialogContent(payment: payment);
    },
  );
}

class _EditDebtPaymentDialogContent extends StatefulWidget {
  final DebtPayment payment;
  const _EditDebtPaymentDialogContent({required this.payment});

  @override
  State<_EditDebtPaymentDialogContent> createState() =>
      _EditDebtPaymentDialogContentState();
}

class _EditDebtPaymentDialogContentState
    extends State<_EditDebtPaymentDialogContent> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _paymentDate;
  int? _selectedDebtId;
  PaymentMethod? _selectedPaymentMethod;

  late final MainController<Debt> debtController;
  late final MainController<PaymentMethod> paymentMethodController;

  List<Debt> debts = [];
  List<PaymentMethod> paymentMethods = [];

  @override
  void initState() {
    super.initState();
    final payment = widget.payment;
    _amountController.text = payment.amount.toString();
    _notesController.text = payment.notes ?? '';
    _paymentDate = payment.createdAt ?? DateTime.now();
    _selectedDebtId = payment.debtId;

    debtController = MainController<Debt>(context: context);
    paymentMethodController = MainController<PaymentMethod>(context: context);

    debtController.fetchAll();
    paymentMethodController.fetchAll();

    if (payment.methodId != null) {
      // This is a simplification. You might need to fetch the specific method.
      _selectedPaymentMethod = PaymentMethod(
        id: payment.methodId!,
        methodName: 'Unknown',
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.payment.id == null ? 'Create Debt Payment' : 'Edit Debt Payment',
      ),
      content: MultiBlocListener(
        listeners: [
          BlocListener<GeneralBloc<Debt>, GeneralState<Debt>>(
            listener: (context, state) {
              if (state is ItemsLoadSuccess<Debt>) {
                setState(() {
                  debts = state.items;
                });
              }
            },
          ),
          BlocListener<GeneralBloc<PaymentMethod>, GeneralState<PaymentMethod>>(
            listener: (context, state) {
              if (state is ItemsLoadSuccess<PaymentMethod>) {
                setState(() {
                  paymentMethods = state.items;
                  if (widget.payment.methodId != null &&
                      _selectedPaymentMethod == null) {
                    _selectedPaymentMethod = paymentMethods.firstWhere(
                      (m) => m.id == widget.payment.methodId,
                    );
                  }
                });
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<int>(
                initialValue: _selectedDebtId,
                hint: const Text('Select Debt'),
                items: debts
                    .map(
                      (debt) => DropdownMenuItem<int>(
                        value: debt.id,
                        child: Text('Debt #${debt.id} - ${debt.partyType}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedDebtId = value),
                decoration: const InputDecoration(labelText: 'Debt'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Payment Date: ${DateFormat.yMd().format(_paymentDate)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _selectedPaymentMethod,
                hint: const Text('Select Payment Method'),
                items: paymentMethods
                    .map(
                      (method) => DropdownMenuItem<PaymentMethod>(
                        value: method,
                        child: Text(method.methodName),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedPaymentMethod = value),
                decoration: const InputDecoration(labelText: 'Payment Method'),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.payment.id == null ? 'Create' : 'Update'),
          onPressed: () {
            // Dispatch add or update event
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
