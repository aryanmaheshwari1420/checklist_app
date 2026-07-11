import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppIconTheme {
  static IconThemeData get lightIconTheme {
    return const IconThemeData(
      color: AppColors.textSecondaryLight,
      opacity: 1.0,
      size: 24,
    );
  }

  static IconThemeData get darkIconTheme {
    return const IconThemeData(
      color: AppColors.textPrimary,
      opacity: 1.0,
      size: 24,
    );
  }

  static IconThemeData get lightPrimaryIconTheme {
    return const IconThemeData(
      color: AppColors.primary,
      opacity: 1.0,
      size: 24,
    );
  }

  static IconThemeData get darkPrimaryIconTheme {
    return const IconThemeData(
      color: AppColors.primaryLight,
      opacity: 1.0,
      size: 24,
    );
  }
}
