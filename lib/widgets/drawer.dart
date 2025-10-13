import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/screens/accounting.dart';
import 'package:ponit_of_sales/screens/home.dart';
import 'package:ponit_of_sales/screens/hr2.dart';
import 'package:ponit_of_sales/screens/inventory.dart';
import 'package:ponit_of_sales/screens/pos.dart';
import 'package:ponit_of_sales/screens/purchases.dart';
import 'package:ponit_of_sales/screens/reports.dart';
import 'package:ponit_of_sales/screens/sales.dart';
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
            gumpTo: HomeScreen(),
            icon: Icons.home,
          ),
          if (tabs.contains("pos"))
            MyDrawerTile(
              name: "POS",
              isActive: activePage == "pos",
              gumpTo: PosScreen(),
              icon: Icons.point_of_sale,
            ),
          if (tabs.contains("sales"))
            MyDrawerTile(
              name: "Sales",
              isActive: activePage == "sales",
              gumpTo: SalesScreen(),
              icon: Icons.shopping_cart_checkout_outlined,
            ),
          if (tabs.contains("accounting"))
            MyDrawerTile(
              name: "Accounting",
              isActive: activePage == "accounting",
              gumpTo: AccountingScreen(),
              icon: Icons.account_balance,
            ),
          if (tabs.contains("purchase"))
            MyDrawerTile(
              name: "Purchases",
              isActive: activePage == "purchases",
              gumpTo: PurchaseScreen(),
              icon: Icons.shopping_cart_outlined,
            ),
          if (tabs.contains("hr"))
            MyDrawerTile(
              name: "HR & Customers",
              isActive: activePage == "hr",
              gumpTo: HR2Screen(),
              icon: Icons.people,
            ),
          if (tabs.contains("reports"))
            MyDrawerTile(
              name: "Reports",
              isActive: activePage == "reports",
              gumpTo: ReportsScreen(),
              icon: Icons.leaderboard,
            ),
          if (tabs.contains("inventory"))
            MyDrawerTile(
              name: "Iventory",
              isActive: activePage == "inventory",
              gumpTo: InventoryScreen(),
              icon: Icons.inventory,
            ),
          MyDrawerTile(
            name: "Settings",
            isActive: activePage == "settings",
            gumpTo: HomeScreen(),
            icon: Icons.settings,
          ),
          MyDrawerTile(
            name: "About",
            isActive: activePage == "about",
            gumpTo: HomeScreen(),
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
    required this.gumpTo,
    required this.icon,
  });
  final String name;
  final bool isActive;
  final Widget gumpTo;
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
        onTap: () {
          if (isActive) {
            return;
          }
          if (gumpTo is HomeScreen) {
            context.pop();
            context.pop();
            return;
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => gumpTo,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    // Example: Scale transition
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                      child: child,
                    );
                  },
              transitionDuration: Duration(milliseconds: 500),
            ),
          );
        },
      ),
    );
  }
}
