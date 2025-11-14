import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/options.dart';
import 'package:ponit_of_sales/models/category.dart';

void showEditOptionTypeDialog(BuildContext context, OptionsType type) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditOptionTypeDialogContent(type: type);
    },
  );
}

class _EditOptionTypeDialogContent extends StatefulWidget {
  final OptionsType type;
  const _EditOptionTypeDialogContent({required this.type});

  @override
  State<_EditOptionTypeDialogContent> createState() =>
      _EditOptionTypeDialogContentState();
}

class _EditOptionTypeDialogContentState
    extends State<_EditOptionTypeDialogContent> {
  final _nameController = TextEditingController();
  int? _selectedCategoryId;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.type.name;
    _selectedCategoryId = widget.type.categoryId;
    // Fetch categories for the dropdown
    context.read<GeneralBloc<ProductCategory>>().add(const LoadItems());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.type.id == null ? 'Create Option Type' : 'Edit Option Type',
      ),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Type Name'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a type name'
                  : null,
            ),
            BlocBuilder<
              GeneralBloc<ProductCategory>,
              GeneralState<ProductCategory>
            >(
              builder: (context, state) {
                if (state is ItemsLoadSuccess<ProductCategory>) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    hint: const Text('Select Category'),
                    items: state.items.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategoryId = value),
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.type.id == null ? 'Create' : 'Update'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newType = OptionsType(
                id: widget.type.id,
                name: _nameController.text,
                categoryId: _selectedCategoryId!,
              );
              context.read<GeneralBloc<OptionsType>>().add(
                newType.id == null
                    ? AddItem(newType)
                    : UpdateItem(itemId: newType.id!, item: newType),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

void showEditOptionValueDialog(BuildContext context, OptionsValue value) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditOptionValueDialogContent(value: value);
    },
  );
}

class _EditOptionValueDialogContent extends StatefulWidget {
  final OptionsValue value;
  const _EditOptionValueDialogContent({required this.value});

  @override
  State<_EditOptionValueDialogContent> createState() =>
      _EditOptionValueDialogContentState();
}

class _EditOptionValueDialogContentState
    extends State<_EditOptionValueDialogContent> {
  final _nameController = TextEditingController();
  int? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.value.name;
    _selectedTypeId = widget.value.typeId;
    context.read<GeneralBloc<OptionsType>>().add(const LoadItems());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.value.id == null ? 'Create Option Value' : 'Edit Option Value',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Value Name'),
          ),
          BlocBuilder<GeneralBloc<OptionsType>, GeneralState<OptionsType>>(
            builder: (context, state) {
              if (state is ItemsLoadSuccess<OptionsType>) {
                return DropdownButtonFormField<int>(
                  initialValue: _selectedTypeId,
                  hint: const Text('Select Option Type'),
                  items: state.items.map((type) {
                    return DropdownMenuItem<int>(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedTypeId = value),
                  validator: (value) =>
                      value == null ? 'Please select a type' : null,
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.value.id == null ? 'Create' : 'Update'),
          onPressed: () {
            final newValue = OptionsValue(
              id: widget.value.id,
              name: _nameController.text,
              typeId: _selectedTypeId!,
            );
            context.read<GeneralBloc<OptionsValue>>().add(
              newValue.id == null
                  ? AddItem(newValue)
                  : UpdateItem(itemId: newValue.id!, item: newValue),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
