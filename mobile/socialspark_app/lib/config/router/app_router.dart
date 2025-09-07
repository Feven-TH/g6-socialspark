import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:socialspark_app/features/authentication/presentation/pages/signup_page.dart';
import 'package:socialspark_app/features/brand/presentation/controller/brand_setup_controller.dart';
import 'package:socialspark_app/features/editor/domain/usecases/update_content.dart';
import 'package:socialspark_app/features/library/presentation/pages/library_page.dart';
import '../../core/services/session_store.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/brand/presentation/pages/brand_setup_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/about/presentation/pages/about_us_page.dart';
import '../../features/editor/presentation/pages/content_editor_page.dart';
import '../../features/editor/presentation/bloc/content_editor_bloc.dart';
import '../../features/editor/data/repositories/content_repository_impl.dart';
import '../../features/editor/domain/usecases/create_content.dart';
import '../../features/editor/data/datasources/content_api_data_source.dart';
import '../../features/editor/presentation/bloc/content_editor_event.dart';

// NEW: Create page route target
import '../../features/create/presentation/pages/create_content_page.dart';
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
          // add more nested home routes here if needed
        ],
      ),

      // Library as a top-level route
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (_, __) => const LibraryPage(),
      ),

      // Editor
      GoRoute(
        path: '/editor',
        name: 'editor',
        builder: (_, __) {
          final client = http.Client();
          final remoteDataSource = ContentApiDataSourceImpl(client: client);
          final contentRepository = ContentRepositoryImpl(remoteDataSource: remoteDataSource);
          final createContent = CreateContent(contentRepository);
          final updateContent = UpdateContent(contentRepository);

          return BlocProvider(
            create: (context) {
              final bloc = ContentEditorBloc(
                createContent: createContent,
                updateContent: updateContent,
              );
              bloc.add(InitializeContent());
              return bloc;
            },
            child: const ContentEditorPage(),
          );
        },
      ),

      // NEW: Create content page (target for FAB)
      GoRoute(
        path: '/create',
        name: 'create',
        builder: (_, __) => const CreateContentPage(),
      ),
      
      // Scheduler page
      GoRoute(
        path: '/scheduler',
        name: 'scheduler',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SchedulerPage(
            item: {
              'image': extra['mediaUrl'],
              'description': extra['caption'],
              'platform': extra['type'] ?? 'instagram',
              'hashtags': extra['hashtags'] ?? [],
            },
          );
        },
      ),
    ],

    redirect: (ctx, state) {
      // allow public routes without redirection
      const publicPaths = <String>{
        '/splash',
        '/login',
        '/signup',
        '/home/about',
      };
      if (publicPaths.contains(state.matchedLocation)) return null;

      switch (session.stage) {
        case AppStage.splash:
          return '/splash';

        case AppStage.unauth:
          return '/login';

        case AppStage.brandSetup:
          return '/brand';

        case AppStage.home:
          // Allow these when authenticated/on home stage
          const allowed = <String>{
            '/home',
            '/home/about',
            '/library',
            '/editor',
            '/create', // ← important: FAB navigates here
            '/scheduler',
          };
          if (allowed.contains(state.matchedLocation)) return null;
          return '/home';
      }
    },
  );
}
