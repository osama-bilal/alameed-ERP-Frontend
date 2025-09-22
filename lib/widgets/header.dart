import 'package:flutter/material.dart';

class MyHeader extends StatelessWidget {
  const MyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = MediaQuery.sizeOf(context).width < 1100;
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (isCompact)
                  IconButton(
                    onPressed: () {
                      if (Scaffold.of(context).isDrawerOpen) {
                        Scaffold.of(context).closeDrawer();
                      } else {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                    icon: Icon(Icons.list),
                  ),

                if (!isCompact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome, Josiah',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Here's what happening in your store."),
                    ],
                  ),
                if (isCompact)
                  const Text(
                    'Welcome, Josiah',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
              ],
            ),

            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isCompact)
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  const SizedBox(width: 10),
                  if (!isCompact)
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {},
                    ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/logo/logo-no-background.png",
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}