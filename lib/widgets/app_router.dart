import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/core/custom_page_transition.dart';
import 'package:ponit_of_sales/screens/home.dart';
import 'package:ponit_of_sales/screens/login.dart';
import 'package:ponit_of_sales/screens/pos.dart';
import 'package:ponit_of_sales/screens/selling.dart';

GoRouter createRouter(BuildContext context) {
  final authBloc = BlocProvider.of<AuthBloc>(context);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authBloc.state is AuthAuthenticated;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      }

      if (loggedIn && loggingIn) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const HomeScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/pos',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const PosScreen()),
      ),
      GoRoute(
        path: '/selling',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const SellScreen()),
      ),
      // Add other routes here using FadeTransitionPage
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
