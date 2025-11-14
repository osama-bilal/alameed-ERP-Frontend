import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/brand.dart';

void showEditBrandDialog(BuildContext context, Brand brand) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditBrandDialogContent(brand: brand);
    },
  );
}

class _EditBrandDialogContent extends StatefulWidget {
  final Brand brand;
  const _EditBrandDialogContent({required this.brand});

  @override
  State<_EditBrandDialogContent> createState() => _EditBrandDialogContentState();
}

class _EditBrandDialogContentState extends State<_EditBrandDialogContent> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.brand.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.brand.id == null ? 'Create Brand' : 'Edit Brand'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Brand Name'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.brand.id == null ? 'Create' : 'Update'),
          onPressed: () {
            final newBrand = Brand(id: widget.brand.id, name: _nameController.text);
            context.read<GeneralBloc<Brand>>().add(newBrand.id == null ? AddItem(newBrand) : UpdateItem(itemId: newBrand.id!, item: newBrand));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
