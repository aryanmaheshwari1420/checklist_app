import 'package:checklist_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
class MemberInviteDialogTheme extends ThemeExtension<MemberInviteDialogTheme> {
  const MemberInviteDialogTheme({
    required this.dialogSurface,
    required this.cardSurface,
    required this.iconCircle,
    required this.closeCircle,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.titleText,
    required this.bodyText,
    required this.mutedText,
    required this.selectedSurface,
    required this.inputSurface,
  });

  final Color dialogSurface;
  final Color cardSurface;
  final Color iconCircle;
  final Color closeCircle;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color titleText;
  final Color bodyText;
  final Color mutedText;
  final Color selectedSurface;
  final Color inputSurface;

  static const light = MemberInviteDialogTheme(
    dialogSurface: Color(0xFFF7FFF9),
    cardSurface: Color(0xFFEAF7EF),
    iconCircle: Color(0xFFD6F5E3),
    closeCircle: Color(0xFFE0F2E7),
    border: Color(0xFFC6E8D0),
    accent: AppColors.primary,
    onAccent: Colors.white,
    titleText: Color(0xFF0A2014),
    bodyText: Color(0xFF355744),
    mutedText: Color(0xFF5F7D6B),
    selectedSurface: Color(0xFFE0F2E7),
    inputSurface: Color(0xFFFFFFFF),
  );

  static const dark = MemberInviteDialogTheme(
    dialogSurface: Color(0xFF0D1A13),
    cardSurface: Color(0xFF13231A),
    iconCircle: Color(0xFF073D25),
    closeCircle: Color(0xFF1A2A21),
    border: Color(0xFF193323),
    accent: AppColors.accentDark,
    onAccent: Colors.black,
    titleText: Colors.white,
    bodyText: Color(0xFFE5ECE8),
    mutedText: Color(0xFF94A39A),
    selectedSurface: Color(0xFF13231A),
    inputSurface: Color(0xFF111C16),
  );

  static MemberInviteDialogTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<MemberInviteDialogTheme>();
    if (extension != null) return extension;
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  @override
  MemberInviteDialogTheme copyWith({
    Color? dialogSurface,
    Color? cardSurface,
    Color? iconCircle,
    Color? closeCircle,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? titleText,
    Color? bodyText,
    Color? mutedText,
    Color? selectedSurface,
    Color? inputSurface,
  }) {
    return MemberInviteDialogTheme(
      dialogSurface: dialogSurface ?? this.dialogSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      iconCircle: iconCircle ?? this.iconCircle,
      closeCircle: closeCircle ?? this.closeCircle,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      titleText: titleText ?? this.titleText,
      bodyText: bodyText ?? this.bodyText,
      mutedText: mutedText ?? this.mutedText,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      inputSurface: inputSurface ?? this.inputSurface,
    );
  }

  @override
  MemberInviteDialogTheme lerp(
    ThemeExtension<MemberInviteDialogTheme>? other,
    double t,
  ) {
    if (other is! MemberInviteDialogTheme) return this;
    return MemberInviteDialogTheme(
      dialogSurface: Color.lerp(dialogSurface, other.dialogSurface, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      iconCircle: Color.lerp(iconCircle, other.iconCircle, t)!,
      closeCircle: Color.lerp(closeCircle, other.closeCircle, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      titleText: Color.lerp(titleText, other.titleText, t)!,
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      inputSurface: Color.lerp(inputSurface, other.inputSurface, t)!,
    );
  }
}
