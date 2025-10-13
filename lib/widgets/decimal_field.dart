import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecimalField extends StatefulWidget {
  const DecimalField({super.key, required this.onChanged, required this.hint});
  final void Function(String)? onChanged;
  final String hint;
  @override
  State<DecimalField> createState() => _DecimalFieldState();
}

class _DecimalFieldState extends State<DecimalField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        hintText: widget.hint,
      ),
      onChanged: widget.onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(
            r'^\d*\.?\d{0,2}',
          ), // allows decimals with up to 2 digits after dot
        ),
      ],
      // onSubmitted: widget.onSubmitted,
    );
  }
}
