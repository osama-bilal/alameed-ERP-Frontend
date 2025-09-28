import 'package:flutter/material.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SharedContent(activeScreen: "settings", child: const Placeholder());
  }
}
