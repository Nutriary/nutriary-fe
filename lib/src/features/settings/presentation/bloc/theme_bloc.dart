import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;
  static const _kThemeModeKey = 'theme_mode';
  static const _kSchemeKey = 'flex_scheme';

  ThemeBloc(this._prefs) : super(const ThemeState()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ChangeScheme>(_onChangeScheme);
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final modeIndex = _prefs.getInt(_kThemeModeKey);
    final schemeIndex = _prefs.getInt(_kSchemeKey);

    ThemeMode mode = ThemeMode.system;
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      mode = ThemeMode.values[modeIndex];
    }

    FlexScheme scheme = FlexScheme.jungle;
    if (schemeIndex != null &&
        schemeIndex >= 0 &&
        schemeIndex < FlexScheme.values.length) {
      scheme = FlexScheme.values[schemeIndex];
    }

    emit(state.copyWith(themeMode: mode, scheme: scheme));
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<ThemeState> emit,
  ) async {
    await _prefs.setInt(_kThemeModeKey, event.mode.index);
    emit(state.copyWith(themeMode: event.mode));
  }

  Future<void> _onChangeScheme(
    ChangeScheme event,
    Emitter<ThemeState> emit,
  ) async {
    await _prefs.setInt(_kSchemeKey, event.scheme.index);
    emit(state.copyWith(scheme: event.scheme));
  }
}
