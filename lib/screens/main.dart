import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/app_router.dart';
import '../blocs/auth/auth_bloc.dart';
// main screens linke login, dashboard, settings, products, invoices, customers, suppliers etc are here
// استيراد شاشاتك

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Builder(
        builder: (context) {
          final router = createRouter(context);

          // 3. استخدام MaterialApp.router
          return MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: "Noto Sans Arabic"),
          );
        },
      ),
    );
  }
}

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // gotoLogin(context);
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
