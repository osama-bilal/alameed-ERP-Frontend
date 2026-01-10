import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/core/custom_page_transition.dart';
import 'package:ponit_of_sales/screens/about_screen.dart';
import 'package:ponit_of_sales/screens/accounting.dart';
import 'package:ponit_of_sales/screens/home.dart';
import 'package:ponit_of_sales/screens/hr2.dart';
import 'package:ponit_of_sales/screens/inventory.dart';
import 'package:ponit_of_sales/screens/login.dart';
import 'package:ponit_of_sales/screens/sale%20pos/pos.dart';
import 'package:ponit_of_sales/screens/purchases.dart';
import 'package:ponit_of_sales/screens/reports.dart';
import 'package:ponit_of_sales/screens/sales.dart';
import 'package:ponit_of_sales/screens/sale%20pos/selling.dart';
import 'package:ponit_of_sales/screens/settings.dart';

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
      GoRoute(
        path: '/sales',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const SalesScreen()),
      ),
      GoRoute(
        path: '/accounting',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const AccountingScreen(),
        ),
      ),
      GoRoute(
        path: '/purchases',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const PurchaseScreen(),
        ),
      ),
      GoRoute(
        path: '/hr',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const HR2Screen()),
      ),
      GoRoute(
        path: '/reports',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ReportsScreen(),
        ),
      ),
      GoRoute(
        path: '/inventory',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const InventoryScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'groups',
            pageBuilder: (context, state) => FadeTransitionPage(
                key: state.pageKey, child: const GroupsManagementScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const AboutScreen()),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
