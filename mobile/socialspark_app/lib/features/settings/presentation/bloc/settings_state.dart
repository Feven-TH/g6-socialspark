import '../../domain/entities/user_entity.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class ProfileUpdated extends SettingsState {
  final UserEntity user;
  ProfileUpdated(this.user);
}

class ThemeUpdated extends SettingsState {
  final String theme;
  ThemeUpdated(this.theme);
}
