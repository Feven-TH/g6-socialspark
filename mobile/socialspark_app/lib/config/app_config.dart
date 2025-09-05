// lib/config/api_config.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // If you're running Android emulator, use the host loopback: 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:8000";
    // iOS simulator & desktop & web can use localhost
    return "http://localhost:8000";
  }

  static const Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
}
