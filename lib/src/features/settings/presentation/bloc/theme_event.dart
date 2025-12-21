import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode mode;
  const ChangeThemeMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ChangeScheme extends ThemeEvent {
  final FlexScheme scheme;
  const ChangeScheme(this.scheme);
  @override
  List<Object?> get props => [scheme];
}
