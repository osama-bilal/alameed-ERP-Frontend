import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/provider/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return DropdownButton<Locale>(
      value: provider.locale,
      icon: const Icon(Icons.language),
      underline: Container(),
      onChanged: (Locale? newValue) {
        if (newValue != null) {
          provider.setLocale(newValue);
        }
      },
      items: const [
        DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
        DropdownMenuItem(value: Locale('en'), child: Text('English')),
      ],
    );
  }
}
