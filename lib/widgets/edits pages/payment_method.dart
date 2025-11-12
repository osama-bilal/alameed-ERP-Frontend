import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/payment_method.dart';

void showEditPaymentMethodDialog(BuildContext context, PaymentMethod method) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditPaymentMethodDialogContent(method: method);
    },
  );
}

class _EditPaymentMethodDialogContent extends StatefulWidget {
  final PaymentMethod method;
  const _EditPaymentMethodDialogContent({required this.method});

  @override
  State<_EditPaymentMethodDialogContent> createState() =>
      _EditPaymentMethodDialogContentState();
}

class _EditPaymentMethodDialogContentState
    extends State<_EditPaymentMethodDialogContent> {
  final _methodNameController = TextEditingController();
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _methodNameController.text = widget.method.methodName;
    _isActive = widget.method.isActive;
  }

  @override
  void dispose() {
    _methodNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.method.id == null
            ? 'Create Payment Method'
            : 'Edit Payment Method',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _methodNameController,
              decoration: const InputDecoration(labelText: 'Method Name'),
            ),
            SwitchListTile(
              title: const Text('Is Active'),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
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
          child: Text(widget.method.id == null ? 'Create' : 'Update'),
          onPressed: () {
            final newMethod = PaymentMethod(
              id: widget.method.id,
              methodName: _methodNameController.text,
              isActive: _isActive,
            );
            context.read<GeneralBloc<PaymentMethod>>().add(
              newMethod.id == null
                  ? AddItem(newMethod)
                  : UpdateItem(itemId: newMethod.id!, item: newMethod),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
