import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/absen/presentation/pages/absen_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/absen/presentation/pages/absen_processing_page.dart';
import '../../features/absen/domain/entities/absen_location_entity.dart';
import '../di/injection_container.dart';
import 'route_constants.dart';

/// Helper untuk menghubungkan Stream (Bloc) ke Listenable GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = sl<AuthBloc>().state;
      final bool isGoingToSplash = state.matchedLocation == AppRoutes.splash;
      final bool isGoingToLogin = state.matchedLocation == AppRoutes.login;

      // Izinkan SplashPage menampilkan animasinya
      if (isGoingToSplash) return null;

      if (authState is AuthAuthenticated) {
        if (isGoingToLogin) {
          return AppRoutes.home;
        }
        return null;
      }

      if (authState is AuthUnauthenticated || authState is AuthFailureState) {
        if (!isGoingToLogin) {
          return AppRoutes.login;
        }
        return null;
      }

      // Jika masih AuthInitial atau AuthLoading di luar splash, tahan route saat ini
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
      GoRoute(
        path: AppRoutes.absen,
        builder: (context, state) => const AbsenPage(),
      ),
      // Rute Pemrosesan Absensi (Liveness & Review)
      GoRoute(
        path: AppRoutes.absenProcessing,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AbsenProcessingPage(
            type: extra['type'] as String? ?? 'MASUK',
            shiftData: extra['dataShift'] as Map<String, dynamic>?,
            absenLocation: extra['absenLocation'] as AbsenLocationEntity?,
          );
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
}
