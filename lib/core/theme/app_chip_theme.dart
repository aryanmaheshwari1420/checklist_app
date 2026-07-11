import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppChipTheme {
  static ChipThemeData get lightChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceAltLight,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.accent,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.light,
      elevation: 0,
    );
  }

  static ChipThemeData get darkChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.accent,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.dark,
      elevation: 0,
    );
  }
}
