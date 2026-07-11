import 'package:checklist_app/core/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';

class AppSwitchTheme {
  static SwitchThemeData light = SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.white),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? lightColorScheme.primary
          : lightColorScheme.outline;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  static SwitchThemeData dark = SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.white),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? darkColorScheme.primary
          : darkColorScheme.outline;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );
}