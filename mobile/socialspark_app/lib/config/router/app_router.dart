// lib/config/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import 'package:socialspark_app/features/authentication/presentation/pages/signup_page.dart';
import 'package:socialspark_app/features/brand/presentation/controller/brand_setup_controller.dart';
import 'package:socialspark_app/features/library/presentation/pages/library_page.dart';
import '../../core/services/session_store.dart';

// PAGES
import '../../features/splash/presentation/pages/splash_page.dart';       // your splash UI with "Get Started"
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/brand/presentation/pages/brand_setup_page.dart';   // your single long scroll page
import '../../features/dashboard/presentation/pages/dashboard_page.dart'; // bottom nav "home"
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/about/presentation/pages/about_us_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

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
      // Settings route at the root level
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsPage(),
      ),
    ],

    // Stage-based redirect, but ALWAYS allow staying on /splash
    redirect: (ctx, state) {
      // 1) Always allow the splash screen and other public routes to be visible
      if (state.matchedLocation == '/splash' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup') {
        return null;
      }
      
      // 2) For authenticated users, allow these routes
      if (session.stage == AppStage.home) {
        if (state.matchedLocation == '/' ||
            state.matchedLocation == '/home' ||
            state.matchedLocation == '/home/about' ||
            state.matchedLocation == '/library' ||
            state.matchedLocation == '/settings') {
          return null;
        }
      }

      // 2) Then gate everything else by the app stage
      switch (session.stage) {
        case AppStage.splash:
          // if we somehow land elsewhere, send back to splash
          return '/splash';
        case AppStage.unauth:
          return state.matchedLocation == '/login' ? null : '/login';
        case AppStage.brandSetup:
          return state.matchedLocation == '/brand' ? null : '/brand';
        case AppStage.home:
          // Default to home if route is not recognized
          if (state.matchedLocation == '/home' ||
              state.matchedLocation == '/home/about' ||
              state.matchedLocation == '/library' ||
              state.matchedLocation == '/settings') {
            return null;
          }
          // If trying to access an unknown route while authenticated, go to home
          return '/home';
      }
    },
  );
}
