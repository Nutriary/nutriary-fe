import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final FlexScheme scheme;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.scheme = FlexScheme.jungle,
  });

  ThemeState copyWith({ThemeMode? themeMode, FlexScheme? scheme}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      scheme: scheme ?? this.scheme,
    );
  }

  @override
  List<Object?> get props => [themeMode, scheme];
}
