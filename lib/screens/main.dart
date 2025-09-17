// main screens linke login, dashboard, settings, products, invoices, customers, suppliers etc are here

// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ponit_of_sales/screens/login.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashWidget(), debugShowCheckedModeBanner: false);
  }
}

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});
  void gotoLogin(BuildContext context) async {
    if (context.mounted) {
      await Future.delayed(Duration(seconds: 3)).then((value) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    gotoLogin(context);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/logo/logo-no-background.png"),
              fit: BoxFit.contain,
              height: 100,
              width: 110,
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
