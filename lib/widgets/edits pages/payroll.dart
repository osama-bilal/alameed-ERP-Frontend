import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '/blocs/auth/auth_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/controllers/provider/parties.dart';
import '/models/payment_method.dart';
import '/models/salarypayment.dart';
import '/utils/pending_operation.dart';
import '/widgets/decimal_field.dart';
import 'package:provider/provider.dart';

class PayrollEditPage extends StatefulWidget {
  final SalaryPayment? payroll;
  const PayrollEditPage({super.key, this.payroll});

  @override
  State<PayrollEditPage> createState() => _PayrollEditPageState();
}

class _PayrollEditPageState extends State<PayrollEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool tried = false;
  late MainController<SalaryPayment> _payrollController;
  late MainController<PaymentMethod> _paymentMethodController;

  // State variables
  int? _selectedPaymentMethodId;
  int? _selectedEmployeeId;
  late DateTime _paymentDate;

  bool get _isEditing => widget.payroll != null;

  @override
  void initState() {
    super.initState();

    _payrollController = MainController<SalaryPayment>(context: context);
    _paymentMethodController = MainController<PaymentMethod>(context: context);

    if (widget.payroll != null) {
      final payroll = widget.payroll!;
      _amountController.text = payroll.amount;
      _notesController.text = payroll.notes ?? '';
      _selectedPaymentMethodId = payroll.paymentMethodId;
      _selectedEmployeeId = payroll.employeeId;
    }
    _paymentDate = widget.payroll?.paymentDate ?? DateTime.now();

    _paymentMethodController.fetchAll();
    context.read<AppParties>().fetchEmployees();
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

  void _savePayroll() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authState = context.read<AuthBloc>().state;
      int? userId;
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      }

      final payrollToSave = SalaryPayment(
        id: widget.payroll?.id,
        employeeId: _selectedEmployeeId!,
        amount: _amountController.text,
        paymentDate: _paymentDate,
        paymentMethodId: _selectedPaymentMethodId!,
        notes: _notesController.text,
        createdById: _isEditing ? widget.payroll?.createdById : userId,
        updatedById: _isEditing ? userId : null,
      );

      if (_isEditing) {
        _payrollController.update(payrollToSave.id!, payrollToSave);
      } else {
        _payrollController.createItem(payrollToSave);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Payroll' : 'Create Payroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePayroll,
            tooltip: 'Save Payroll',
          ),
        ],
      ),
      body: BlocListener<GeneralBloc<SalaryPayment>, GeneralState<SalaryPayment>>(
        listener: (context, state) {
          if (state is ItemOperationSuccess<SalaryPayment> &&
              (state.operation == OperationType.add ||
                  state.operation == OperationType.update)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payroll saved successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is ItemLoadFailure<SalaryPayment>) {
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
                      initialValue: _selectedEmployeeId,
                      hint: const Text('Select Employee'),
                      items: employees.map((employee) {
                        return DropdownMenuItem<int>(
                          value: employee.id,
                          child: Text(employee.toString()),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedEmployeeId = value),
                      decoration: const InputDecoration(labelText: 'Employee'),
                      validator: (value) => _selectedEmployeeId == null
                          ? 'Please select an employee'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
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
                    if (methods.isEmpty) {
                      return const Text("No payment methods found.");
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
