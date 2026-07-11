import 'package:flutter/material.dart';
import 'package:ledgerbook/core/theme/app_color_scheme.dart';

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