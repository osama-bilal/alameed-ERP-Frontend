import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/models/category.dart';

void showEditCategoryDialog(BuildContext context, ProductCategory category) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditCategoryDialogContent(category: category);
    },
  );
}

class _EditCategoryDialogContent extends StatefulWidget {
  final ProductCategory category;
  const _EditCategoryDialogContent({required this.category});

  @override
  State<_EditCategoryDialogContent> createState() =>
      _EditCategoryDialogContentState();
}

class _EditCategoryDialogContentState
    extends State<_EditCategoryDialogContent> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category.name;
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
        widget.category.id == null ? 'Create Category' : 'Edit Category',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
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
          child: Text(widget.category.id == null ? 'Create' : 'Update'),
          onPressed: () {
            final newCategory = ProductCategory(
              id: widget.category.id,
              name: _nameController.text,
            );
            context.read<GeneralBloc<ProductCategory>>().add(
              newCategory.id == null
                  ? AddItem(newCategory)
                  : UpdateItem(itemId: newCategory.id!, item: newCategory),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
