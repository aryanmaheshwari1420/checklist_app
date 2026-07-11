import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppProgressIndicatorTheme {
  static ProgressIndicatorThemeData get lightProgressIndicatorTheme {
    return ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearMinHeight: 4,
      linearTrackColor: AppColors.dividerLight,
      refreshBackgroundColor: AppColors.surfaceLight,
      circularTrackColor: AppColors.dividerLight,
    );
  }

  static ProgressIndicatorThemeData get darkProgressIndicatorTheme {
    return ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearMinHeight: 4,
      linearTrackColor: AppColors.border,
      refreshBackgroundColor: AppColors.surfaceAlt,
      circularTrackColor: AppColors.border,
    );
  }
}
