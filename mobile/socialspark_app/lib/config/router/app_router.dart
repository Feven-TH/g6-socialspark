import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:socialspark_app/features/authentication/presentation/pages/signup_page.dart';
import 'package:socialspark_app/features/brand/presentation/controller/brand_setup_controller.dart';
import 'package:socialspark_app/features/library/presentation/pages/library_page.dart';
import '../../core/services/session_store.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/brand/presentation/pages/brand_setup_page.dart';
import '../../features/about/presentation/pages/about_us_page.dart';
import '../../features/editor/presentation/pages/content_editor_page.dart';
import '../../features/editor/presentation/bloc/content_editor_bloc.dart';
import '../../features/editor/data/repositories/content_repository_impl.dart';
import '../../features/editor/domain/usecases/create_content.dart';
import '../../features/editor/domain/usecases/update_content.dart';
import '../../features/editor/data/datasources/content_api_data_source.dart';
import '../../features/editor/presentation/bloc/content_editor_event.dart';

// Main tab pages
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/create/presentation/pages/create_content_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

// Scheduler
import '../../features/scheduling/presentation/pages/scheduler_page.dart';

// Needed for MediaType used by the /scheduler route
import '../../features/library/data/models/library_item.dart';

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

      // HOME (with nested About)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomePage(),
        routes: [
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (_, __) => const AboutUsPage(),
          ),
        ],
      ),

      // LIBRARY
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (_, __) => const LibraryPage(),
      ),

      // CREATE
      GoRoute(
        path: '/create',
        name: 'create',
        builder: (_, __) => const CreateContentPage(),
      ),

      // SETTINGS
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsPage(),
      ),

      // EDITOR (standalone)
      GoRoute(
        path: '/editor',
        name: 'editor',
        builder: (_, __) {
          final client = http.Client();
          final remoteDataSource = ContentApiDataSourceImpl(client: client);
          final contentRepository =
              ContentRepositoryImpl(remoteDataSource: remoteDataSource);
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

      // SCHEDULER (single, unified version)
      GoRoute(
        path: '/scheduler',
        name: 'scheduler',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final mediaUrl = (extra['mediaUrl'] as String?) ?? '';
          final caption = (extra['caption'] as String?) ?? '';
          final platform = (extra['platform'] as String?) ?? 'instagram';

          // Accept both `type` or `mediaType`
          final typeStr = ((extra['type'] ?? extra['mediaType']) as String? ?? 'image')
              .toString()
              .toLowerCase();
          final type =
              typeStr.contains('video') ? MediaType.video : MediaType.image;

          return SchedulerPage(
            mediaUrl: mediaUrl,
            caption: caption,
            platform: platform,
            type: type,
          );
        },
      ),
    ],

    redirect: (ctx, state) {
      // Public routes allowed without auth
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
          const allowed = <String>{
            '/home',
            '/home/about',
            '/library',
            '/create',
            '/settings',
            '/editor',
            '/scheduler',
          };
          if (allowed.contains(state.matchedLocation)) return null;
          return '/home';
      }
    },
  );
}
