import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/language_selector.dart';
import 'package:ponit_of_sales/widgets/shared_content.dart';
import 'package:ponit_of_sales/controllers/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:ponit_of_sales/widgets/dataPages/groups.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showLogoutConfirmationDialog() {
            final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(l10n.confirmLogout),
          content: Text(l10n.sureToLogOut),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.logOut),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                context.read<AuthBloc>().add(LoggedOut());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
            final l10n = AppLocalizations.of(context)!;

    final themeProvider = Provider.of<ThemeProvider>(context);
    // Check if the user has any permissions for the 'groups' table.
    final canManageGroups = tablePermissions(
      context,
      'group',
    ).values.any((p) => p);

    return SharedContent(
      activeScreen: "settings",
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard(
            context,
            title: l10n.appearance,
            children: [
              SwitchListTile(
                title: Text(l10n.darkMode),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  themeProvider.setTheme(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ],
          ),
          LanguageSelector(),
          _buildSettingsCard(
            context,
            title: l10n.account,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.logOut),
                onTap: _showLogoutConfirmationDialog,
              ),
            ],
          ),
          if (canManageGroups)
            _buildSettingsCard(
              context,
              title: l10n.admin,
              children: [
                ListTile(
                  leading: const Icon(Icons.group_work_outlined),
                  title: Text(l10n.manageGroups),
                  onTap: () {
                    context.push('/settings/groups');
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class GroupsManagementScreen extends StatelessWidget {
  const GroupsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
            final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageGroups)),
      body: const Padding(padding: EdgeInsets.all(16.0), child: GroupsPage()),
    );
  }
}
