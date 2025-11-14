import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/models/stockmovement.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';

class StockAdjustmentPage extends StatefulWidget {
  const StockAdjustmentPage({super.key});

  @override
  State<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

enum AdjustmentType { increase, decrease }

class _StockAdjustmentPageState extends State<StockAdjustmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  late MainController<StockMovement> _movementController;

  // State variables
  int? _selectedVariantId;
  AdjustmentType _adjustmentType = AdjustmentType.increase;

  @override
  void initState() {
    super.initState();
    _movementController = MainController<StockMovement>(context: context);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAdjustment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authState = context.read<AuthBloc>().state;
      int? userId;
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      }

      int quantity = int.tryParse(_quantityController.text) ?? 0;
      if (_adjustmentType == AdjustmentType.decrease) {
        quantity = -quantity;
      }

      final movementToSave = StockMovement(
        variantId: _selectedVariantId!,
        quantity: quantity,
        movementType: 'adjustment',
        userId: userId,
        movementDate: DateTime.now(),
        notes: _notesController.text,
      );

      _movementController.createItem(movementToSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Stock Adjustment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAdjustment,
            tooltip: 'Save Adjustment',
          ),
        ],
      ),
      body:
          BlocListener<GeneralBloc<StockMovement>, GeneralState<StockMovement>>(
            listener: (context, state) {
              if (state is ItemOperationSuccess<StockMovement> &&
                  state.operation == OperationType.add) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adjustment saved successfully!'),
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is ItemLoadFailure<StockMovement>) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      errorBuilder: (context, errorText) => Text(errorText),
                      initialValue: _selectedVariantId,
                      hint: const Text('Select Product Variant'),
                      items: context.watch<ProductsProvider>().pros.map((
                        POSView variant,
                      ) {
                        return DropdownMenuItem<int>(
                          value: variant.id,
                          child: Text(variant.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedVariantId = value),
                      decoration: const InputDecoration(
                        labelText: 'Product Variant',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a variant' : null,
                    ),
                    const SizedBox(height: 16),
                    RadioGroup(
                      onChanged: (value) {
                        if (value != null && mounted) {
                          setState(() {
                            _adjustmentType = value;
                          });
                        }
                      },
                      groupValue: _adjustmentType,
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<AdjustmentType>(
                              title: const Text('Increase'),
                              value: AdjustmentType.increase,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<AdjustmentType>(
                              title: const Text('Decrease'),
                              value: AdjustmentType.decrease,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    DecimalField(
                      controller: _quantityController,
                      hint: "Quantity",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid positive quantity';
                        }
                        return null;
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
