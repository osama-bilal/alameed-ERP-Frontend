import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/screens/home.dart';
import 'package:ponit_of_sales/screens/login.dart';
import 'package:ponit_of_sales/screens/main.dart';

// استورد ملفات الـ BLoC والشاشات الخاصة بك
import '../blocs/auth/auth_bloc.dart';
// import 'auth_state.dart';
// import 'screens/home_screen.dart'; 
// import 'screens/login_screen.dart';
// import 'screens/splash_screen.dart'; 
// ... الخ

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// هذا المكون المساعد يحول دفق (Stream) الـ BLoC إلى قائمة قابلة للاستماع (Listenable)
// ليتمكن GoRouter من الاستماع للتغييرات.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// دالة تهيئة الـ Router
GoRouter createRouter(BuildContext context) {
  // الوصول لـ AuthBloc عبر سياق الـ BuildContext
  final authBloc = BlocProvider.of<AuthBloc>(context);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // يبدأ التطبيق من شاشة التحميل للتحقق من التوكن
    initialLocation: '/splash', 

    // 🌟 استمع لأي تغيير في حالة الـ BLoC لإعادة تقييم المسارات
    refreshListenable: GoRouterRefreshStream(authBloc.stream), 

    // 🚨 منطق التحويل (Redirect) الأساسي 🚨
    redirect: (BuildContext context, GoRouterState state) {
      // الحصول على الحالة الحالية للـ BLoC
      final authState = authBloc.state; 

      // تعريف المسارات الهامة
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplashing = state.matchedLocation == '/splash';
      
      // 1. معالجة حالة البدء والتحميل
      if (authState is AuthInitial || authState is AuthLoading) {
        // إذا كنا في حالة تحميل، اسمح فقط بالوصول لشاشة /splash
        return isSplashing ? null : '/splash';
      }

      // 2. معالجة المستخدم المُصادَق (مسجل دخول)
      if (authState is AuthAuthenticated) {
        // إذا كان مسجل دخول وحاول الذهاب لشاشات الدخول أو التحميل، قم بتحويله إلى الشاشة الرئيسية
        if (isLoggingIn || isSplashing) {
          return '/home';
        }
        // وإلا، اسمح له بالوصول للمسار المطلوب (مثل /profile)
        return null;
      }

      // 3. معالجة المستخدم غير المُصادَق (غير مسجل دخول)
      if (authState is AuthUnauthenticated) {
        // إذا كان غير مسجل دخول وحاول الوصول لأي مكان غير شاشة /login
        if (!isLoggingIn) {
          return '/login'; // تحويله إجبارياً إلى شاشة تسجيل الدخول
        }
        // وإلا، اسمح له بالبقاء في شاشة تسجيل الدخول
        return null;
      }

      // لا حاجة لإعادة التوجيه (Fallback)
      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashWidget()),
      GoRoute(path: '/login', builder: (context, state) =>  LoginScreen()),
      // المسارات المحمية تبدأ من هنا
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}