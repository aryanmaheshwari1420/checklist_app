import 'package:checklist_app/core/theme/app_color_scheme.dart';
import 'package:checklist_app/core/theme/app_switch_theme.dart';
import 'package:flutter/material.dart';
import 'app_appbar_theme.dart';
import 'app_bottom_sheet_theme.dart';
import 'app_button_theme.dart';
import 'app_card_theme.dart';
import 'app_chip_theme.dart';
import 'app_colors.dart';
import 'app_dialog_theme.dart';
import 'app_icon_theme.dart';
import 'app_input_decoration_theme.dart';
import 'app_progress_indicator_theme.dart';
import 'app_text_theme.dart';
import 'member_invite_dialog_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,
      secondaryHeaderColor: AppColors.accent,
      dividerColor: AppColors.dividerLight,

      // Text Theme
      textTheme: AppTextTheme.lightTextTheme(),
      appBarTheme: AppAppBarTheme.lightAppBarTheme,
      cardTheme: AppCardTheme.lightCardTheme,
      elevatedButtonTheme: AppButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: AppButtonTheme.lightOutlinedButtonTheme,
      textButtonTheme: AppButtonTheme.lightTextButtonTheme,
      inputDecorationTheme: AppInputDecorationTheme.lightInputDecorationTheme,
      iconTheme: AppIconTheme.lightIconTheme,
      primaryIconTheme: AppIconTheme.lightPrimaryIconTheme,
      chipTheme: AppChipTheme.lightChipTheme,
      dialogTheme: AppDialogTheme.lightDialogTheme,
      bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
      progressIndicatorTheme:
          AppProgressIndicatorTheme.lightProgressIndicatorTheme,
      extensions: const <ThemeExtension<dynamic>>[
        MemberInviteDialogTheme.light,
      ],

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),

      switchTheme: AppSwitchTheme.light,

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      secondaryHeaderColor: AppColors.accent,
      dividerColor: AppColors.divider,
      // Text Theme
      textTheme: AppTextTheme.darkTextTheme(),
      appBarTheme: AppAppBarTheme.darkAppBarTheme,
      cardTheme: AppCardTheme.darkCardTheme,
      elevatedButtonTheme: AppButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: AppButtonTheme.darkOutlinedButtonTheme,
      textButtonTheme: AppButtonTheme.darkTextButtonTheme,
      inputDecorationTheme: AppInputDecorationTheme.darkInputDecorationTheme,
      iconTheme: AppIconTheme.darkIconTheme,
      primaryIconTheme: AppIconTheme.darkPrimaryIconTheme,
      chipTheme: AppChipTheme.darkChipTheme,
      dialogTheme: AppDialogTheme.darkDialogTheme,
      bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
      progressIndicatorTheme:
          AppProgressIndicatorTheme.darkProgressIndicatorTheme,
      extensions: const <ThemeExtension<dynamic>>[MemberInviteDialogTheme.dark],

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryLight, width: 3),
        ),
      ),

      switchTheme: AppSwitchTheme.dark,

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}