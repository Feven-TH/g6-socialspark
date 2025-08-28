import 'package:flutter/material.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/registration_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegistrationPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("No route defined"))),
        );
    }
  }
}
