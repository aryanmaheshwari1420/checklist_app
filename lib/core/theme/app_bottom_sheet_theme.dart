import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBottomSheetTheme {
  static BottomSheetThemeData get lightBottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      modalElevation: 16,
      modalBackgroundColor: AppColors.surfaceLight,
      constraints: BoxConstraints(minWidth: double.infinity),
      clipBehavior: Clip.antiAlias,
    );
  }

  static BottomSheetThemeData get darkBottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceAlt,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      modalElevation: 16,
      modalBackgroundColor: AppColors.surfaceAlt,
      constraints: BoxConstraints(minWidth: double.infinity),
      clipBehavior: Clip.antiAlias,
    );
  }
}
