import 'package:socialspark_app/features/settings/domain/repositories/settings_repository.dart';


class UpdateTheme {
  final SettingsRepository repository;

  UpdateTheme(this.repository);

  Future<void> call(String theme) async {
    return await repository.updateTheme(theme);
  }
}
