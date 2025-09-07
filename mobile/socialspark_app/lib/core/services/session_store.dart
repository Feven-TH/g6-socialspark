// lib/core/services/session_store.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppStage { splash, unauth, brandSetup, home }

class SessionStore extends ChangeNotifier {
  static const _kLoggedIn = 'logged_in';
  static const _kBrandDone = 'brand_done';

  AppStage _stage = AppStage.splash;
  AppStage get stage => _stage;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final logged = sp.getBool(_kLoggedIn) ?? false;
    final brand = sp.getBool(_kBrandDone) ?? false;

    if (!logged) {
      _stage = AppStage.unauth;
    } else if (!brand) {
      _stage = AppStage.brandSetup;
    } else {
      _stage = AppStage.home;
    }
    notifyListeners();
  }

  Future<void> fakeLogin() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kLoggedIn, true);
    _stage = AppStage.brandSetup;
    notifyListeners();
  }

  Future<void> completeBrandSetup() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kBrandDone, true);
    _stage = AppStage.home;
    notifyListeners();
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kLoggedIn);
    await sp.remove(_kBrandDone);
    _stage = AppStage.unauth;
    notifyListeners();
  }
}
