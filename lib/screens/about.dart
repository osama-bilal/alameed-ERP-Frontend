import 'package:flutter/widgets.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return SharedContent(activeScreen: "about", child: const Placeholder());
  }
}
