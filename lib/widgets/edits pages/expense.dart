import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/shift.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';

class ExpenseEditPage extends StatefulWidget {
  final Expense expense;
  const ExpenseEditPage({super.key, required this.expense});

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late MainController<Expense> _expenseController;
  late MainController<PaymentMethod> _paymentMethodController;
  late PartyController _partyController;

  // State variables
  int? _selectedPaymentMethodId;
  int? _selectedTakenByEmployeeId;
  String? _selectedReason;

  bool get _isEditing => widget.expense.id != null;

  final List<String> _reasons = ['office', 'refund', 'withdrawal', 'other'];

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _expenseController = MainController<Expense>(context: context);
    _paymentMethodController = MainController<PaymentMethod>(context: context);
    _partyController = PartyController(context: context);

    _amountController.text = expense.amount;
    _notesController.text = expense.notes ?? '';
    _selectedPaymentMethodId = expense.paymentMethodId;
    _selectedTakenByEmployeeId = expense.takenByEmployeeId;
    _selectedReason = expense.reason;

    _paymentMethodController.fetchAll();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveExpense() {
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

      final authState = context.read<AuthBloc>().state;
      int? userId;
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      }

      final expenseToSave = Expense(
        id: widget.expense.id,
        shiftId: shift.id!,
        recordedById: userId,
        amount: _amountController.text,
        notes: _notesController.text,
        paymentMethodId: _selectedPaymentMethodId,
        takenByEmployeeId: _selectedTakenByEmployeeId,
        reason: _selectedReason,
      );

      if (_isEditing) {
        _expenseController.update(expenseToSave.id!, expenseToSave);
      } else {
        _expenseController.createItem(expenseToSave);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Create Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpense,
            tooltip: 'Save Expense',
          ),
        ],
      ),
      body: BlocListener<GeneralBloc<Expense>, GeneralState<Expense>>(
        listener: (context, state) {
          if (state is ItemOperationSuccess<Expense> &&
              (state.operation == OperationType.add ||
                  state.operation == OperationType.update)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense saved successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is ItemLoadFailure<Expense>) {
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
                  initialValue: _selectedReason,
                  hint: const Text('Select Reason'),
                  items: _reasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedReason = value),
                  decoration: const InputDecoration(labelText: 'Reason'),
                  validator: (value) =>
                      value == null ? 'Please select a reason' : null,
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
                FutureBuilder<List<ViewParty<Employee>>>(
                  future: _partyController.fethEmployees(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading employees: ${snapshot.error}');
                    }
                    final employees = snapshot.data ?? [];
                    return DropdownButtonFormField<int>(
                      initialValue: _selectedTakenByEmployeeId,
                      hint: const Text('Taken By (Optional)'),
                      items: employees.map((employee) {
                        return DropdownMenuItem<int>(
                          value: employee.id,
                          child: Text(employee.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTakenByEmployeeId = value),
                      decoration: const InputDecoration(
                        labelText: 'Taken By Employee',
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
