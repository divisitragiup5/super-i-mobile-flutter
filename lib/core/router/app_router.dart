import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../di/injection_container.dart';
import '../storage/secure_storage_service.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) async {
      final secureStorage = sl<SecureStorageService>();
      final token = await secureStorage.getAccessToken();

      final bool isLoggedIn = token != null && token.isNotEmpty;
      final bool isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final bool isGoingToSplash = state.matchedLocation == AppRoutes.splash;

      if (isGoingToSplash) return null;

      if (!isLoggedIn && !isGoingToLogin) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isGoingToLogin) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // 1. Splash Page
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // 2. Login Page
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // 3. Stateful Bottom Navigation Tabs (Home & Akun)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Tab Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Branch 1: Tab Akun
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.akun,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
}
