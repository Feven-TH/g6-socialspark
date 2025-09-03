import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/user_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    return await localDataSource.updateProfile(
      UserModel(fullName: user.fullName, email: user.email, profilePic: user.profilePic),
    );
  }

  @override
  Future<void> updateTheme(String theme) async {
    return await localDataSource.updateTheme(theme);
  }
}
