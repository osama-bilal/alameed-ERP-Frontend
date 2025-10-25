import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/utils/allowed_tabs.dart';

class MyDrawer extends StatelessWidget {
  final String activePage;
  const MyDrawer({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    final tabs = allowedHomeTabs(context);
    return Drawer(
      backgroundColor: Colors.grey[200],
      width: 270,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          SizedBox(height: 70),
          MyDrawerTile(
            name: "Home",
            isActive: activePage == "home",
            path: '/',
            icon: Icons.home,
          ),
          if (tabs.contains("pos"))
            MyDrawerTile(
              name: "POS",
              isActive: activePage == "pos",
              path: '/pos',
              icon: Icons.point_of_sale,
            ),
          if (tabs.contains("sales"))
            MyDrawerTile(
              name: "Sales",
              isActive: activePage == "sales",
              path: '/sales',
              icon: Icons.shopping_cart_checkout_outlined,
            ),
          if (tabs.contains("accounting"))
            MyDrawerTile(
              name: "Accounting",
              isActive: activePage == "accounting",
              path: '/accounting',
              icon: Icons.account_balance,
            ),
          if (tabs.contains("purchase"))
            MyDrawerTile(
              name: "Purchases",
              isActive: activePage == "purchases",
              path: '/purchases',
              icon: Icons.shopping_cart_outlined,
            ),
          if (tabs.contains("hr"))
            MyDrawerTile(
              name: "HR & Customers",
              isActive: activePage == "hr",
              path: '/hr',
              icon: Icons.people,
            ),
          if (tabs.contains("reports"))
            MyDrawerTile(
              name: "Reports",
              isActive: activePage == "reports",
              path: '/reports',
              icon: Icons.leaderboard,
            ),
          if (tabs.contains("inventory"))
            MyDrawerTile(
              name: "Iventory",
              isActive: activePage == "inventory",
              path: '/inventory',
              icon: Icons.inventory,
            ),
          MyDrawerTile(
            name: "Settings",
            isActive: activePage == "settings",
            path: '/settings',
            icon: Icons.settings,
          ),
          MyDrawerTile(
            name: "About",
            isActive: activePage == "about",
            path: '/about',
            icon: Icons.info_outline,
          ),
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
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListTile(
        selected: isActive,
        selectedTileColor: Colors.lightBlueAccent,
        selectedColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        tileColor: Colors.grey[350],
        leading: Icon(icon),
        title: Text(name, style: TextStyle(fontFamily: "Noto Sans Arabic")),
        onTap: () async {
          // Close the drawer if it's open
          if (Scaffold.of(context).isDrawerOpen) {
            Scaffold.of(context).closeDrawer();
          }
          // Use GoRouter for navigation
          context.push(path);
        },
      ),
    );
  }
}
