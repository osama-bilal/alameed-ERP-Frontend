import 'package:flutter/material.dart';
import 'package:ponit_of_sales/screens/pos.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [SizedBox(height: 200)],
              // hera is the main header where display the user's name and the other informations
            ),

            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.7,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => PosScreen())),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: Icon(
                            Icons.point_of_sale,
                            size: MediaQuery.sizeOf(context).width / 4,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "POS",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
