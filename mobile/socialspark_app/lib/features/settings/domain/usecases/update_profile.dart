import '../entities/user_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateProfile {
  final SettingsRepository repository;

  UpdateProfile(this.repository);

  Future<UserEntity> call(UserEntity user) async {
    return await repository.updateProfile(user);
  }
}
