import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class SettingsLocalDataSource {
  Future<UserModel> updateProfile(UserModel user);
  Future<void> updateTheme(String theme);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  UserModel? cachedUser;
  String currentTheme = "light";

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    cachedUser = user;
    return cachedUser!;
  }

  @override
  Future<void> updateTheme(String theme) async {
    currentTheme = theme;
  }
}
