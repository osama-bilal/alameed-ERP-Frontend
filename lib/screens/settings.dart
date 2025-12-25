import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
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
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
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
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
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
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _showLogoutConfirmationDialog,
              ),
            ],
          ),
          if (canManageGroups)
            _buildSettingsCard(
              context,
              title: 'Admin',
              children: [
                ListTile(
                  leading: const Icon(Icons.group_work_outlined),
                  title: const Text('Manage Groups'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Groups')),
      body: const Padding(padding: EdgeInsets.all(16.0), child: GroupsPage()),
    );
  }
}
