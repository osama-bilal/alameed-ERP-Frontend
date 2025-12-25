import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception(AppLocalizations.of(context)!.couldNotLaunchUrl(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.companyName, style: textTheme.headlineMedium),
            Text(l10n.appName, style: textTheme.titleLarge),
            const SizedBox(height: 24),
            Text(l10n.appDescription),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchUrl(
                context,
                'https://github.com/osama-bilal/alameed_erp',
              ),
              child: Text(
                l10n.githubLinkText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.developmentPhaseNote),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(l10n.personalJourneyTitle, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(l10n.personalJourneyText1),
            const SizedBox(height: 12),
            Text(l10n.personalJourneyText2),
            const SizedBox(height: 12),
            Text(l10n.personalJourneyText3),
            const SizedBox(height: 24),
            Text(
              l10n.dedicationText,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            Center(child: Text(l10n.madeWithLove)),
          ],
        ),
      ),
    );
  }
}
