import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:socialspark_app/features/brand/presentation/controller/brand_setup_controller.dart';
import 'package:socialspark_app/features/library/presentation/pages/library_page.dart';
import 'package:socialspark_app/features/scheduling/presentation/pages/scheduler_page.dart';
import '../../core/services/session_store.dart';

// PAGES
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/brand/presentation/pages/brand_setup_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/about/presentation/pages/about_us_page.dart';

GoRouter buildRouter(SessionStore session) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: session, // rebuild when stage changes
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
          path: '/brand',
          name: 'brand',
          builder: (_, __) => ChangeNotifierProvider(
                create: (_) => BrandSetupController(),
                child: const BrandSetupPage(),
              )),
      // HOME = dashboard with the bottom nav bar
      GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, __) => const DashboardPage(),
          routes: [
            GoRoute(
              path: 'about',
              name: 'about',
              builder: (_, __) => const AboutUsPage(),
            ),
          ]),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (_, __) => const LibraryPage(),
      ),
      GoRoute(
        path: '/scheduler',
        name: 'scheduler',
        builder: (context, state) {
          final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
          final Map<String, dynamic> item = extra['item'] as Map<String, dynamic>;
          final int index = extra['index'] as int;

          return SchedulerPage(
            contentPath: item['image'] as String?,
            caption: item['description'] as String?,
            platform: item['platform'] as String?,
            itemIndex: index,
          );
        },
      ),
    ],

    // Stage-based redirect
    redirect: (ctx, state) {
      if (state.matchedLocation == '/splash') return null;
      if (state.matchedLocation == '/login') return null;
      if (state.matchedLocation == '/signup') return null;
      if (state.matchedLocation == '/home/about') return null;

      switch (session.stage) {
        case AppStage.splash:
          return '/splash';
        case AppStage.unauth:
          return state.matchedLocation == '/login' ? null : '/login';
        case AppStage.brandSetup:
          return state.matchedLocation == '/brand' ? null : '/brand';
        case AppStage.home:
          return null; // Allow all paths for logged-in users
      }
    },
  );
}
