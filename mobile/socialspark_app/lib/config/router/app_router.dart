import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:socialspark_app/features/authentication/presentation/pages/signup_page.dart';
import 'package:socialspark_app/features/brand/presentation/controller/brand_setup_controller.dart';
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
import '../../features/editor/domain/usecases/update_content.dart';
import 'package:http/http.dart' as http;

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
          // Assuming settings and scheduler were from the other branch and are being kept
          // If you need to add settings and scheduler back, you'll need to re-add those routes
        ],
      ),

      // Library as a top-level route
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (_, __) => const LibraryPage(),
      ),
      
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
    ],

    redirect: (ctx, state) {
      if (state.matchedLocation == '/splash') return null;
      if (state.matchedLocation == '/login') return null;
      if (state.matchedLocation == '/signup') return null;
      if (state.matchedLocation == '/home/about') return null;

      switch (session.stage) {
        case AppStage.splash:
          return '/splash';
        case AppStage.unauth:
          return '/login';
        case AppStage.brandSetup:
          return '/brand';
        case AppStage.home:
          if (state.matchedLocation == '/home' ||
              state.matchedLocation == '/home/about' ||
              state.matchedLocation == '/library' ||
              state.matchedLocation == '/editor') {
            return null;
          }
          return '/home';
      }
      return null;
    }, 
  );
}