import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/app_parties.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';

class DebtEditPage extends StatefulWidget {
  final Debt debt;
  const DebtEditPage({super.key, required this.debt});

  @override
  State<DebtEditPage> createState() => _DebtEditPageState();
}

class _DebtEditPageState extends State<DebtEditPage> {
  final partyTypes = {
    'customer': 'Customers',
    'supplier': 'Suppliers',
    'employee': 'Employees',
  };

  final kind = {'product': 'Invoice', 'cash': 'Cash', 'previous': 'Previous'};

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _dueDate;
  late PartyController _partyController;
  late MainController<Debt> _debtController;

  // State variables
  String? _partyType;
  ViewParty? _selectedParty;
  String? _selectedKind;
  int? _selectedSourceContentType;
  int? _selectedSourceId;
  bool get _isEditing => widget.debt.id != null;

  @override
  void initState() {
    super.initState();
    final debt = widget.debt;
    _partyController = PartyController(context: context);
    _debtController = MainController<Debt>(context: context);

    _amountController.text = debt.amount ?? '0.0';
    _notesController.text = debt.notes ?? '';
    _dueDate = debt.dueDate ?? DateTime.now();
    _partyType = debt.partyType;
    _selectedKind = debt.kind;
    _selectedSourceContentType = debt.sourceContentType;
    _selectedSourceId = debt.sourceId;

    // If editing, we need to fetch the party to display its name
    if (_isEditing && debt.partyId != null && debt.partyType != null) {
      _fetchAndSetInitialParty(debt.partyType!, debt.partyId!);
    }
  }

  void _fetchAndSetInitialParty(String type, int id) async {
    List<ViewParty> parties = [];
    switch (type) {
      case 'customer':
        parties = context.read<AppParties>().customers.toList();
        break;
      case 'supplier':
        parties = context.read<AppParties>().suppliers.toList();
        break;
      case 'employee':
        parties = context.read<AppParties>().employees.toList();
        break;
    }
    if (mounted) {
      setState(() {
        _selectedParty = parties.firstWhere(
          (p) => p.id == id,
          orElse: () => ViewParty(id: id, name: "Not Found!"),
        );
      });
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
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final debtToSave = Debt(
        id: widget.debt.id,
        partyType: _partyType,
        partyId: _selectedParty?.id,
        kind: _selectedKind,
        sourceContentType: _selectedSourceContentType,
        sourceId: _selectedSourceId,
        amount: _amountController.text,
        dueDate: _dueDate,
        notes: _notesController.text,
        status: widget.debt.status, // Preserve status
      );

      if (_isEditing) {
        _debtController.update(debtToSave.id!, debtToSave);
      } else {
        _debtController.createItem(debtToSave);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Debt' : 'Create Debt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDebt,
            tooltip: 'Save Debt',
          ),
        ],
      ),
      body: BlocListener<GeneralBloc<Debt>, GeneralState<Debt>>(
        listener: (context, state) {
          if (state is ItemOperationSuccess<Debt> &&
              (state.operation == OperationType.add ||
                  state.operation == OperationType.update)) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Debt saved successfully!')));
            Navigator.of(context).pop();
          } else if (state is ItemLoadFailure<Debt>) {
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
                // 1. Party Type Selector
                DropdownButtonFormField<String>(
                  initialValue: _partyType,
                  hint: const Text('Select Party Type'),
                  items: partyTypes.entries.map((m) {
                    return DropdownMenuItem<String>(
                      value: m.key,
                      child: Text(m.value),
                    );
                  }).toList(),
                  onChanged: _isEditing
                      ? null
                      : (value) {
                          setState(() {
                            _partyType = value;
                            _selectedParty = null;
                            _selectedKind = null;
                            _selectedSourceContentType = null;
                            _selectedSourceId = null;
                          });
                        },
                  decoration: const InputDecoration(labelText: 'Party Type'),
                  validator: (value) =>
                      value == null ? 'Please select a party type' : null,
                ),
                const SizedBox(height: 16),

                // 2. Party Selector
                if (_partyType != null) _buildPartySelector(),
                const SizedBox(height: 16),

                // 3. Kind Selector
                if (_selectedParty != null)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedKind,
                    hint: const Text('Select Debt Kind'),
                    items: kind.entries.map((m) {
                      return DropdownMenuItem<String>(
                        value: m.key,
                        child: Text(m.value),
                      );
                    }).toList(),
                    onChanged: _isEditing
                        ? null
                        : (value) {
                            setState(() {
                              _selectedKind = value;
                              _selectedSourceContentType = null;
                              _selectedSourceId = null;
                            });
                          },
                    decoration: const InputDecoration(labelText: 'Kind'),
                    validator: (value) =>
                        value == null ? 'Please select a kind' : null,
                  ),
                const SizedBox(height: 16),
                if (_selectedKind != null &&
                    _selectedParty != null &&
                    _selectedKind != 'previous')
                  _buildSourceContentTypeSelector(),
                const SizedBox(height: 16),
                // 4. Source Selector (conditionally)
                if (_selectedKind != 'previous' &&
                    _selectedSourceContentType != null &&
                    _selectedParty != null)
                  _buildSourceSelector(),
                const SizedBox(height: 16),

                // 5. Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled:
                      _selectedKind ==
                      'previous', // Amount is editable only for 'previous' balance
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 6. Due Date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due Date: ${DateFormat.yMd().format(_dueDate)}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. Notes
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

  Widget _buildPartySelector() {
    return Builder(
      builder: (context) {
        List<ViewParty> parties = [];
        switch (_partyType) {
          case 'customer':
            parties = context.read<AppParties>().customers.toList();
            break;
          case 'supplier':
            parties = context.read<AppParties>().suppliers.toList();
            break;
          case 'employee':
            parties = context.read<AppParties>().employees.toList();
            break;
        }
        if (parties.isEmpty) {
          return const Text(
            "No available source found for this party and kind.",
          );
        }
        return DropdownButtonFormField<ViewParty>(
          initialValue: _selectedParty,
          hint: const Text('Select Party'),
          items: parties.map((party) {
            return DropdownMenuItem<ViewParty>(
              value: party,
              child: Text(party.name),
            );
          }).toList(),
          onChanged: _isEditing
              ? null
              : (value) {
                  setState(() {
                    _selectedParty = value;
                    _selectedKind = null;
                    _selectedSourceContentType = null;
                    _selectedSourceId = null;
                  });
                },
          decoration: const InputDecoration(labelText: 'Party'),
          validator: (value) => value == null ? 'Please select a party' : null,
        );
      },
    );
  }

  Widget _buildSourceContentTypeSelector() {
    return Builder(
      builder: (context) {
        final sources = context.read<AppParties>().contentTypes;

        final filterdParties = <ViewParty>[];
        if (_selectedKind == 'product' && _partyType == 'customer') {
          filterdParties.addAll(
            sources.where(
              (element) => element.name.toLowerCase().contains('sale invoice'),
            ),
          );
        } else if (_selectedKind == 'product' && _partyType == 'supplier') {
          filterdParties.addAll(
            sources.where(
              (element) =>
                  element.name.toLowerCase().contains('purchase invoice'),
            ),
          );
        } else if (_selectedKind == 'cash' && _partyType == 'employee') {
          filterdParties.addAll(
            sources.where(
              (element) => element.name.toLowerCase().contains('expense'),
            ),
          );
        }

        if (filterdParties.isEmpty) {
          return const Text(
            "No available source found for this party and kind.",
          );
        }
        return DropdownButtonFormField<int>(
          initialValue: _selectedSourceContentType,
          hint: const Text('Content Type'),
          items: filterdParties.map((party) {
            return DropdownMenuItem<int>(
              value: party.id,
              child: Text(party.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSourceContentType = value;
              _selectedSourceId = null;
            });
          },
          decoration: const InputDecoration(labelText: 'Party'),
        );
      },
    );
  }

  Widget _buildSourceSelector() {
    return FutureBuilder<List<ViewParty>>(
      future: _fetchSourceContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error loading source: ${snapshot.error}');
        }
        final sources = snapshot.data ?? [];
        if (sources.isEmpty) {
          return const Text(
            "No available source found for this party and kind.",
          );
        }

        return DropdownButtonFormField<int>(
          initialValue: _selectedSourceId,
          hint: const Text('Select Source'),
          items: sources.map((source) {
            return DropdownMenuItem<int>(
              value: source.id,
              child: Text(source.name),
            );
          }).toList(),
          onChanged: _isEditing
              ? null
              : (value) {
                  setState(() {
                    _selectedSourceId = value;
                    // When a source is selected, we should update the amount from it
                    // final selectedSource = sources.firstWhere(
                    //   (s) => s.id == value,
                    // );
                    // This assumes the 'name' contains amount info, which is brittle.
                    // A better API would return the amount directly.
                    // For now, we'll just set \it.
                    // _amountController.text = "Fetch from source";
                  });
                },
          decoration: const InputDecoration(labelText: 'Source Document'),
          validator: (value) => value == null ? 'Please select a source' : null,
        );
      },
    );
  }

  Future<List<ViewParty>> _fetchSourceContent() async {
    if (_selectedKind == null || _selectedParty == null) {
      return [];
    }
    switch (_selectedKind) {
      case "product":
        if (_partyType == "customer") {
          return await _partyController.fetchWithEndpoint<SaleInvoice>(
            "customers/${_selectedParty!.id}/sales",
          );
        } else if (_partyType == "supplier") {
          return await _partyController.fetchWithEndpoint<PurchaseInvoice>(
            "suppliers/${_selectedParty!.id}/purchase",
          );
        }
        break;
      case "cash":
        if (_partyType == "employee") {
          return await _partyController.fetchWithEndpoint<Expense>(
            "employees/${_selectedParty!.id}/expenses",
          );
        }
        break;
    }
    return [];
  }
}
