import 'package:checklist_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppCardTheme {
  static CardThemeData get lightCardTheme {
    return CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: AppColors.surfaceLight,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static CardThemeData get darkCardTheme {
    return CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: AppColors.surfaceAlt,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }
}
