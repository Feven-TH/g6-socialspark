// lib/config/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/session_store.dart';

// PAGES
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';

import '../../features/brand/presentation/controller/brand_setup_controller.dart';
import '../../features/brand/presentation/pages/brand_setup_page.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/about/presentation/pages/about_us_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/library/presentation/pages/library_page.dart';

// Create page
import '../../features/create/presentation/pages/create_content_page.dart';

// Scheduler page
import '../../features/scheduling/presentation/pages/scheduler_page.dart';

GoRouter buildRouter(SessionStore session) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: session,
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
        path: '/signup',
        name: 'signup',
        builder: (_, __) => const SignUpPage(),
      ),

      GoRoute(
        path: '/brand',
        name: 'brand',
        builder: (_, __) => ChangeNotifierProvider(
          create: (_) => BrandSetupController(),
          child: const BrandSetupPage(),
        ),
      ),

      // HOME = dashboard with nested pages
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
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: 'scheduler',
            name: 'scheduler',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SchedulerPage(
                item: extra?['item'],
                index: extra?['index'],
              );
            },
          ),
        ],
      ),

      // Library as a top-level route
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (_, __) => const LibraryPage(),
      ),

      // Create content page (FAB should go here)
      GoRoute(
        path: '/create',
        name: 'create',
        builder: (_, __) => const CreateContentPage(),
      ),
    ],

    // Stage-based redirect (+ allow-list of routes that should never be blocked)
    redirect: (ctx, state) {
      final loc = state.matchedLocation;

      // Always allow these unauthenticated
      if (loc == '/splash' || loc == '/login' || loc == '/signup') return null;

      // Allow standalone pages accessible after login
      // (create/library) and any nested home route (/home, /home/...)
      if (loc == '/brand' ||
          loc == '/library' ||
          loc == '/create' ||
          loc.startsWith('/home')) {
        // Gate by stage
        switch (session.stage) {
          case AppStage.splash:
            return '/splash';
          case AppStage.unauth:
            return '/login';
          case AppStage.brandSetup:
            // if user hasn't finished brand setup, force it
            return loc == '/brand' ? null : '/brand';
          case AppStage.home:
            // authenticated; allow /home, /home/*, /library, /create, etc.
            return null;
        }
      }

      // Fallbacks by stage
      switch (session.stage) {
        case AppStage.splash:
          return '/splash';
        case AppStage.unauth:
          return '/login';
        case AppStage.brandSetup:
          return '/brand';
        case AppStage.home:
          return '/home';
      }
    },
  );
}
