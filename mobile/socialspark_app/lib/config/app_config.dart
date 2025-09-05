import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // Android emulator must use 10.0.2.2 for host loopback
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:8000";
    // iOS simulator, desktop, web → localhost
    return "http://localhost:8000";
  }

  static const Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
}
