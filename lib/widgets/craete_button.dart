import 'package:flutter/material.dart';

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({
    super.key,
    required this.onPressed,
    this.label = "Create New",
  });
  final void Function() onPressed;
  final String label;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        iconColor: WidgetStatePropertyAll(Colors.black),
      ),
      onPressed: onPressed,
      label: Text(label, style: TextStyle(color: Colors.black)),
      icon: Icon(Icons.add),
    );
  }
}
