// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router/app_router.dart';
import 'core/services/session_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = SessionStore();
  await session.init();
  runApp(AppRoot(session: session));
}

class AppRoot extends StatelessWidget {
  final SessionStore session;
  const AppRoot({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      child: Builder(
        builder: (context) {
          final router = buildRouter(session);
          return MaterialApp.router(
            title: 'SocialSpark',
            theme: ThemeData(useMaterial3: true),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
