import 'package:flutter/material.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/l10n/extention.dart';

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({
    super.key,
    required this.onPressed,
    this.label = "New",
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
      label: Text(AppLocalizations.of(context)!.get(label), style: TextStyle(color: Colors.black)),
      icon: Icon(Icons.add),
    );
  }
}
