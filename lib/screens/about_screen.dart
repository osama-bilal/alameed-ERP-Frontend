import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About Alameed ERP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alameed Telecom', style: textTheme.headlineMedium),
            Text('Alameed ERP Application', style: textTheme.titleLarge),
            const SizedBox(height: 24),
            const Text(
              'This application was developed with Flutter as the client-side for the Alameed Telecom shop ERP (Enterprise Resource Planning) project.',
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () =>
                  _launchUrl('https://github.com/osama-bilal/alameed_erp'),
              child: Text(
                'The application serves as the interface to control and manage data on the server, which you can find on GitHub.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The project is still in the development phase and requires significant upgrades to reach its full potential.',
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text('A Personal Journey', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text(
              'This front-end application was developed by Osama Bilal using Flutter. The project began in September 2025, following his graduation from computer college and after accompanying his mother on her treatment journey from parosteal osteosarcoma in Egypt.',
            ),
            const SizedBox(height: 12),
            const Text(
              'The main project was established as a way of expressing gratitude to his father and to fulfill the need for this system in their store.',
            ),
            const SizedBox(height: 12),
            const Text(
              "This project is the result of over two and a half months of dedicated work, and development is ongoing to add features and fix issues.",
            ),
            const SizedBox(height: 24),
            const Text(
              'This was done with love, giving all the love and respect to my parents. I am grateful for their efforts to teach me and to raise me with a good education. I can only tell them, "May God reward you for me with the best reward." Whatever I do and whatever I give you, I will not be able to reward you for what you have given me.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const Center(child: Text('Made with love. ❤️')),
          ],
        ),
      ),
    );
  }
}
