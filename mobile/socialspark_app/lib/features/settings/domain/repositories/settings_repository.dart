import '../entities/user_entity.dart';

abstract class SettingsRepository {
  Future<UserEntity> updateProfile(UserEntity user);
  Future<void> updateTheme(String theme);
}
