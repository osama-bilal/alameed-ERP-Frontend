import 'package:flutter/material.dart';
// import 'package:ponit_of_sales/screens/login.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/widgets/app_router.dart';
import '../blocs/auth/auth_bloc.dart';
// main screens linke login, dashboard, settings, products, invoices, customers, suppliers etc are here
// استيراد شاشاتك

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // توفير الـ AuthBloc لجميع أجزاء التطبيق
    return BlocProvider(
      create: (context) => AuthBloc(), 
      child: Builder( // نستخدم Builder للوصول إلى سياق الـ BlocProvider
        builder: (context) {
          // 2. إنشاء وتكوين الـ Router
          final router = createRouter(context); 
          
          // 3. استخدام MaterialApp.router
          return MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         if (state is AuthInitial || state is AuthLoading) {
//           // 1. عرض شاشة انتظار/تحميل أثناء التحقق من التوكن
//           return MaterialApp(
//             home: Scaffold(body: Center(child: CircularProgressIndicator())),
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(fontFamily: "Noto Sans Arabic"),
//           );
//         } else if (state is AuthAuthenticated) {
//           // 2. المستخدم مسجل دخول: عرضه الشاشة الرئيسية
//           return MaterialApp(
//             // استخدم GoRouter هنا لتطبيق التوجيه المحكم (Redirect)
//             home: const HomeScreen(),
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(fontFamily: "Noto Sans Arabic"),
//           );
//         } else if (state is AuthUnauthenticated) {
//           // 3. المستخدم غير مسجل دخول: عرض شاشة تسجيل الدخول
//           return MaterialApp(home: LoginScreen());
//         }
//         // حالة افتراضية (قد تحتاج إلى شاشة خطأ)
//         return MaterialApp(
//           home: Scaffold(body: Center(child: Text('Error'))),
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(fontFamily: "Noto Sans Arabic"),
//         );
//       },
//     );
//   }
// }
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SplashWidget(),
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(fontFamily: "Noto Sans Arabic"),
//     );
//   }
// }

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});
  // void gotoLogin(BuildContext context) async {
  //   Future.delayed(Duration(seconds: 3)).then((value) {
  //     if (context.mounted) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => LoginScreen()),
  //       );
  //     }
  //   });
  // }

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
