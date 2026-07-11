import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppAppBarTheme {
  static AppBarThemeData get lightAppBarTheme {
    return const AppBarThemeData(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimaryLight,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 56,
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      actionsIconTheme: IconThemeData(
        color: AppColors.textPrimaryLight,
        size: 24,
      ),
    );
  }

  static AppBarThemeData get darkAppBarTheme {
    return const AppBarThemeData(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 56,
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
    );
  }
}
