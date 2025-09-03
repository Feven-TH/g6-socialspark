import '../../domain/entities/user_entity.dart';

abstract class SettingsEvent {}

class UpdateProfileEvent extends SettingsEvent {
  final UserEntity user;
  UpdateProfileEvent(this.user);
}

class UpdateThemeEvent extends SettingsEvent {
  final String theme;
  UpdateThemeEvent(this.theme);
}
