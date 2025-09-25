import 'package:flutter/material.dart';

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({super.key, required this.onPressed});
  final void Function() onPressed;
  final String label = "Create New";
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        iconColor: WidgetStatePropertyAll(Colors.black),
      ),
      onPressed: onPressed,
      label: Text(label, style: TextStyle(fontSize: 16, color: Colors.black)),
      icon: Icon(Icons.add),
    );
  }
}
