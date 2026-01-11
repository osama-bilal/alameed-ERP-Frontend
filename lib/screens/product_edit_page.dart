import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/brand.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/options.dart';
import 'package:ponit_of_sales/models/product.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
import 'package:ponit_of_sales/widgets/decimal_field.dart';

class ProductEditPage extends StatefulWidget {
  final Product? product;

  const ProductEditPage({super.key, this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  int? _selectedBrandId;
  int? _selectedCategoryId;

  List<ProductVariant> _variants = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _isActive = widget.product?.isActive ?? true;
    _selectedBrandId = widget.product?.brandId;
    _selectedCategoryId = widget.product?.categoryId;
    fetchRelatedData();
    // Fetch related data
    context.read<GeneralBloc<Brand>>().add(LoadItems());
    context.read<GeneralBloc<ProductCategory>>().add(LoadItems());
    context.read<GeneralBloc<OptionsValue>>().add(LoadItems());
  }

  Future<void> fetchRelatedData() async {
    if (widget.product?.id != null) {
      final vars = await AppService.variantService.fetchList(
        queryParams: {'product': widget.product!.id},
      );
      if (mounted) {
        setState(() {
          _variants = vars;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        brandId: _selectedBrandId,
        categoryId: _selectedCategoryId,
        isActive: _isActive,
      );

      if (product.id == null) {
        context.read<GeneralBloc<Product>>().add(AddItem(product));
      } else {
        context.read<GeneralBloc<Product>>().add(
          UpdateItem(item: product, itemId: product.id!),
        );
      }
    }
  }

  void _addOrEditVariant([ProductVariant? variant, int? index]) {
    final isEditing = variant != null;
    final costController = TextEditingController(text: variant?.cost ?? '');
    final priceController = TextEditingController(text: variant?.price ?? '');
    final barcodeController = TextEditingController(
      text: variant?.barcode ?? '',
    );
    final quantityController = TextEditingController(
      text: variant?.quantity.toString() ?? '0',
    );
    List<int> selectedOptionValues = List<int>.from(
      variant?.optionValueIds ?? [],
    );
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? l10n.editVariant : l10n.addVariant),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecimalField(controller: costController, hint: l10n.cost),
                    const SizedBox(height: 8),
                    DecimalField(controller: priceController, hint: l10n.price),
                    const SizedBox(height: 8),
                    TextField(
                      controller: barcodeController,
                      decoration: InputDecoration(labelText: l10n.barcode),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: l10n.quantity),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<
                      GeneralBloc<OptionsValue>,
                      GeneralState<OptionsValue>
                    >(
                      builder: (context, state) {
                        if (state is GeneralLoadInProgress<OptionsValue>) {
                          return Text(l10n.loading);
                        }
                        if (state is ItemsLoadSuccess<OptionsValue>) {
                          return Wrap(
                            spacing: 8.0,
                            children: state.items.map((option) {
                              return FilterChip(
                                label: Text(option.name),
                                selected: selectedOptionValues.contains(
                                  option.id,
                                ),
                                onSelected: (selected) {
                                  setStateDialog(() {
                                    if (selected) {
                                      selectedOptionValues.add(option.id!);
                                    } else {
                                      selectedOptionValues.remove(option.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newVariant = ProductVariant(
                      id: variant?.id,
                      productId:
                          widget.product?.id ??
                          0, // This will be set on the backend for new products
                      cost: costController.text,
                      price: priceController.text,
                      barcode: barcodeController.text,
                      quantity: int.tryParse(quantityController.text) ?? 0,
                      optionValueIds: selectedOptionValues,
                    );
                    setState(() {
                      if (isEditing && index != null) {
                        _variants[index] = newVariant;
                      } else {
                        _variants.add(newVariant);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? l10n.createProduct : l10n.editProduct),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProduct),
        ],
      ),
      body: BlocListener<GeneralBloc<Product>, GeneralState<Product>>(
        listener: (context, state) {
          if (state is ItemOperationSuccess<Product>) {
            if (state.operation == OperationType.add && state.item != null) {
              for (var pv in _variants) {
                pv.productId = state.item!.id!;
                context.read<GeneralBloc<ProductVariant>>().add(AddItem(pv));
              }
            } else if (state.operation == OperationType.update) {
              for (var v in _variants) {
                if (v.id == null) {
                  context.read<GeneralBloc<ProductVariant>>().add(AddItem(v));
                } else {
                  context.read<GeneralBloc<ProductVariant>>().add(
                    UpdateItem(item: v, itemId: v.id!),
                  );
                }
              }
            }
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productDetails,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.productName),
                  validator: (value) =>
                      value!.isEmpty ? l10n.pleaseEnterAName : null,
                  maxLength: 100,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: l10n.description),
                  maxLines: 3,
                ),
                BlocBuilder<GeneralBloc<Brand>, GeneralState<Brand>>(
                  builder: (context, state) {
                    if (state is ItemsLoadSuccess<Brand>) {
                      if (state.items.isEmpty) {
                        return IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) {
                              final name = TextEditingController();
                              return AlertDialog(
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<GeneralBloc<Brand>>().add(
                                        AddItem(Brand(name: name.text)),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(l10n.add),
                                  ),
                                ],
                                content: TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                    labelText: l10n.brandName,
                                  ),
                                  onChanged: (value) => name.text = value,
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return DropdownButtonFormField<int>(
                        errorBuilder: (context, errorText) => Text(errorText),
                        initialValue: _selectedBrandId,
                        hint: Text(l10n.selectBrand),
                        items: state.items.map((brand) {
                          return DropdownMenuItem<int>(
                            value: brand.id,
                            child: Text(brand.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBrandId = value),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                BlocBuilder<
                  GeneralBloc<ProductCategory>,
                  GeneralState<ProductCategory>
                >(
                  builder: (context, state) {
                    if (state is ItemsLoadSuccess<ProductCategory>) {
                      if (state.items.isEmpty) {
                        return IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) {
                              final name = TextEditingController();
                              return AlertDialog(
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<GeneralBloc<ProductCategory>>()
                                          .add(
                                            AddItem(
                                              ProductCategory(name: name.text),
                                            ),
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(l10n.add),
                                  ),
                                ],
                                content: TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                    labelText: l10n.categoryName,
                                  ),
                                  onChanged: (value) => name.text = value,
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return DropdownButtonFormField<int>(
                        errorBuilder: (context, errorText) => Text(errorText),
                        initialValue: _selectedCategoryId,
                        hint: Text(l10n.selectCategory),
                        items: state.items.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategoryId = value),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.isActive),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.variants,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () => _addOrEditVariant(),
                    ),
                  ],
                ),
                const Divider(),
                _buildVariantsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariantsList() {
        final l10n = AppLocalizations.of(context)!;

    if (_variants.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(l10n.novariantsAddedClickTheButtonToAddOne),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _variants.length,
      itemBuilder: (context, index) {
        final variant = _variants[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text('${l10n.price}: ${variant.price} | ${l10n.quantity}: ${variant.quantity}'),
            subtitle: Text(
              '${l10n.barcode}: ${variant.barcode}\n${l10n.cost}: ${variant.cost}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _addOrEditVariant(variant, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _variants.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
