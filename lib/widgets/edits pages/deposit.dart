import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/shift.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';
import 'package:provider/provider.dart';

class DepositEditPage extends StatefulWidget {
  final Deposit deposit;
  const DepositEditPage({super.key, required this.deposit});

  @override
  State<DepositEditPage> createState() => _DepositEditPageState();
}

class _DepositEditPageState extends State<DepositEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late MainController<Deposit> _depositController;
  late MainController<PaymentMethod> _paymentMethodController;
  bool tried = false;
  // State variables
  int? _selectedPaymentMethodId;
  int? _selectedDepositedFromEmployeeId;
  String? _selectedReason;

  bool get _isEditing => widget.deposit.id != null;

  final _reasons = {
    "admin_deposit": "إيداع من الإدارة",
    "refund": "إرجاع فلوس",
    "other": "أخرى",
  };
  @override
  void initState() {
    super.initState();
    final deposit = widget.deposit;
    _depositController = MainController<Deposit>(context: context);
    _paymentMethodController = MainController<PaymentMethod>(context: context);

    _amountController.text = deposit.amount;
    _notesController.text = deposit.notes ?? '';
    _selectedPaymentMethodId = deposit.paymentMethodId;
    _selectedDepositedFromEmployeeId = deposit.depositedFromEmployeeId;
    _selectedReason = deposit.reason;

    _paymentMethodController.fetchAll();
  }

  String? Function(dynamic)? validator = (dynamic value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    return null;
  };

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveDeposit() {
    final authState = context.read<AuthBloc>().state;
    int? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
      if (authState.user.isAdmin) {
        validator = (dynamic s) => null;
      }
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final shift = context.read<ShiftProvider>().current;
      if (shift == null || shift.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active shift found. Please open a shift first.'),
          ),
        );
        return;
      }

      final depositToSave = Deposit(
        id: widget.deposit.id,
        shiftId: shift.id!,
        recordedById: userId,
        amount: _amountController.text,
        notes: _notesController.text,
        paymentMethodId: _selectedPaymentMethodId,
        depositedFromEmployeeId: _selectedDepositedFromEmployeeId,
        reason: _selectedReason,
      );

      if (_isEditing) {
        _depositController.update(depositToSave.id!, depositToSave);
      } else {
        _depositController.createItem(depositToSave);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Deposit' : 'Create Deposit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDeposit,
            tooltip: 'Save Deposit',
          ),
        ],
      ),
      body: BlocListener<GeneralBloc<Deposit>, GeneralState<Deposit>>(
        listener: (context, state) {
          if (state is ItemOperationSuccess<Deposit> &&
              (state.operation == OperationType.add ||
                  state.operation == OperationType.update)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deposit saved successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is ItemLoadFailure<Deposit>) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DecimalField(
                  controller: _amountController,
                  hint: "Amount",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid positive amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  errorBuilder: (context, errorText) => Text(errorText),
                  initialValue: _selectedReason,
                  hint: const Text('Select Reason'),
                  items: _reasons.entries.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason.key,
                      child: Text(reason.value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedReason = value),
                  decoration: const InputDecoration(labelText: 'Reason'),
                  validator: validator,
                ),
                const SizedBox(height: 16),
                BlocBuilder<
                  GeneralBloc<PaymentMethod>,
                  GeneralState<PaymentMethod>
                >(
                  builder: (context, state) {
                    if (state is GeneralLoadInProgress<PaymentMethod>) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<PaymentMethod> methods = [];
                    if (state is ItemsLoadSuccess<PaymentMethod>) {
                      methods = state.items;
                    }
                    return DropdownButtonFormField<int>(
                      errorBuilder: (context, errorText) => Text(errorText),
                      initialValue: _selectedPaymentMethodId,
                      hint: const Text('Select Payment Method'),
                      items: methods.map((method) {
                        return DropdownMenuItem<int>(
                          value: method.id,
                          child: Text(method.methodName),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPaymentMethodId = value),
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                      ),
                      validator: (value) => value == null
                          ? 'Please select a payment method'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<AppParties>(
                  builder: (context, appParties, snapshot) {
                    final employees = appParties.employees;
                    if (employees.isEmpty && !tried) {
                      tried = true;
                      appParties.fetchEmployees();
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (employees.isEmpty) {
                      return const Text("No employees found.");
                    }
                    return DropdownButtonFormField<int>(
                      errorBuilder: (context, errorText) => Text(errorText),
                      initialValue: _selectedDepositedFromEmployeeId,
                      hint: const Text('Deposited From (Optional)'),
                      items: employees.map((employee) {
                        return DropdownMenuItem<int>(
                          value: employee.id,
                          child: Text(employee.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(
                        () => _selectedDepositedFromEmployeeId = value,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Deposited From Employee',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
