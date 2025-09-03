import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_theme.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UpdateProfile updateProfile;
  final UpdateTheme updateTheme;

  SettingsBloc({required this.updateProfile, required this.updateTheme}) : super(SettingsInitial()) {
    on<UpdateProfileEvent>((event, emit) async {
      final user = await updateProfile(event.user);
      emit(ProfileUpdated(user));
    });

    on<UpdateThemeEvent>((event, emit) async {
      await updateTheme(event.theme);
      emit(ThemeUpdated(event.theme));
    });
  }
}
