import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/utils/allowed_tabs.dart';

class MyDrawer extends StatelessWidget {
  final String activePage;
  const MyDrawer({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;

    final tabs = allowedHomeTabs(context);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      width: 270,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          SizedBox(height: 70),
          MyDrawerTile(
            name: l10n.home,
            isActive: activePage == "home",
            path: '/',
            icon: Icons.home,
          ),
          if (tabs.contains("pos"))
            MyDrawerTile(
              name: l10n.pos,
              isActive: activePage == "pos",
              path: '/pos',
              icon: Icons.point_of_sale,
            ),
          if (tabs.contains("sales"))
            MyDrawerTile(
              name: l10n.sales,
              isActive: activePage == "sales",
              path: '/sales',
              icon: Icons.shopping_cart_checkout_outlined,
            ),
          if (tabs.contains("accounting"))
            MyDrawerTile(
              name: l10n.accounting,
              isActive: activePage == "accounting",
              path: '/accounting',
              icon: Icons.account_balance,
            ),
          if (tabs.contains("purchase"))
            MyDrawerTile(
              name: l10n.purchases,
              isActive: activePage == "purchases",
              path: '/purchases',
              icon: Icons.shopping_cart_outlined,
            ),
          if (tabs.contains("hr"))
            MyDrawerTile(
              name: l10n.hr,
              isActive: activePage == "hr",
              path: '/hr',
              icon: Icons.people,
            ),
          if (tabs.contains("reports"))
            MyDrawerTile(
              name: l10n.reports,
              isActive: activePage == "reports",
              path: '/reports',
              icon: Icons.leaderboard,
            ),
          if (tabs.contains("inventory"))
            MyDrawerTile(
              name: l10n.inventory,
              isActive: activePage == "inventory",
              path: '/inventory',
              icon: Icons.inventory,
            ),
          MyDrawerTile(
            name: l10n.settings,
            isActive: activePage == "settings",
            path: '/settings',
            icon: Icons.settings,
          ),
          // MyDrawerTile(
          //   name: l10n.about,
          //   isActive: activePage == "about",
          //   path: '/about',
          //   icon: Icons.info_outline,
          // ),
        ],
      ),
    );
  }
}

class MyDrawerTile extends StatelessWidget {
  const MyDrawerTile({
    super.key,
    required this.name,
    required this.isActive,
    required this.path,
    required this.icon,
  });
  final String name;
  final bool isActive;
  final String path;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListTile(
        selected: isActive,
        selectedTileColor: theme.colorScheme.primary,
        selectedColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        tileColor: theme.colorScheme.surface,
        leading: Icon(icon),
        title: Text(name, style: TextStyle(fontFamily: "Noto Sans Arabic")),
        onTap: () async {
          if (Scaffold.of(context).isDrawerOpen) {
            Scaffold.of(context).closeDrawer();
          }
          context.push(path);
        },
      ),
    );
  }
}
