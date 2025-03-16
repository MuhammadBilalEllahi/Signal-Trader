import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MyTheme {
  // Shadcn Colors
  static final Color background = HexColor("#030711");
  static final Color foreground = HexColor("#FCFCFC");
  static final Color card = HexColor("#1C1C1C");
  static final Color cardForeground = HexColor("#FCFCFC");
  static final Color popover = HexColor("#1C1C1C");
  static final Color popoverForeground = HexColor("#FCFCFC");
  static final Color primary = HexColor("#FACC15"); // Yellow primary
  static final Color primaryForeground = HexColor("#18181B");
  static final Color secondary = HexColor("#27272A");
  static final Color secondaryForeground = HexColor("#FAFAFA");
  static final Color muted = HexColor("#27272A");
  static final Color mutedForeground = HexColor("#A1A1AA");
  static final Color accent = HexColor("#27272A");
  static final Color accentForeground = HexColor("#FAFAFA");
  static final Color destructive = HexColor("#7F1D1D");
  static final Color destructiveForeground = HexColor("#FAFAFA");
  static final Color border = HexColor("#27272A");
  static final Color input = HexColor("#27272A");
  static final Color ring = HexColor("#FACC15");

  // Light Theme Colors
  static final Color backgroundLight = HexColor("#f2f2f2");
  static final Color foregroundLight = HexColor("#09090B");
  static final Color cardLight = HexColor("#f1f1f1");
  static final Color cardForegroundLight = HexColor("#09090B");
  static final Color popoverLight = HexColor("#FFFFFF");
  static final Color popoverForegroundLight = HexColor("#09090B");
  static final Color primaryLight = HexColor("#FACC15");
  static final Color primaryForegroundLight = HexColor("#09090B");
  static final Color secondaryLight = HexColor("#F4F4F5");
  static final Color secondaryForegroundLight = HexColor("#09090B");
  static final Color mutedLight = HexColor("#F4F4F5");
  static final Color mutedForegroundLight = HexColor("#71717A");
  static final Color accentLight = HexColor("#F4F4F5");
  static final Color accentForegroundLight = HexColor("#09090B");
  static final Color borderLight = HexColor("#cfcfcf");
  static final Color inputLight = HexColor("#E4E4E7");
  static final Color ringLight = HexColor("#FACC15");

  static InputDecorationTheme _buildInputTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? input : inputLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: isDark ? border : borderLight,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: isDark ? border : borderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: isDark ? ring : ringLight,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: destructive,
          width: 1,
        ),
      ),
      labelStyle: TextStyle(
        color: isDark ? mutedForeground : mutedForegroundLight,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        color: isDark ? mutedForeground : mutedForegroundLight,
        fontSize: 14,
      ),
      prefixIconColor: isDark ? mutedForeground : mutedForegroundLight,
      suffixIconColor: isDark ? mutedForeground : mutedForegroundLight,
    );
  }

  static ButtonStyle _buildElevatedButtonStyle({required bool isDark}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return (isDark ? primary : primaryLight).withOpacity(0.5);
        }
        if (states.contains(WidgetState.pressed)) {
          return (isDark ? primary : primaryLight).withOpacity(0.9);
        }
        return isDark ? primary : primaryLight;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return (isDark ? primaryForeground : primaryForegroundLight).withOpacity(0.5);
        }
        return isDark ? primaryForeground : primaryForegroundLight;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return (isDark ? primary : primaryLight).withOpacity(0.8);
        }
        return null;
      }),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
    );
  }

  static ButtonStyle _buildOutlinedButtonStyle({required bool isDark}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return (isDark ? accent : accentLight).withOpacity(0.1);
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return isDark ? foreground : foregroundLight;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return (isDark ? accent : accentLight).withOpacity(0.05);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(
          color: isDark ? border : borderLight,
          width: 1,
        );
      }),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
  }

  static ThemeData _buildTheme({required bool isDark}) {
    final baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? background : backgroundLight,
      colorScheme: isDark
          ? ColorScheme.dark(
              surface: card,
              primary: primary,
              secondary: secondary,
              onPrimary: primaryForeground,
              onSecondary: secondaryForeground,
              onSurface: cardForeground,
            )
          : ColorScheme.light(
              surface: cardLight,
              primary: primaryLight,
              secondary: secondaryLight,
              onPrimary: primaryForegroundLight,
              onSecondary: secondaryForegroundLight,
              onSurface: cardForegroundLight,
            ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: TextStyle(
          color: isDark ? foreground : foregroundLight,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: isDark ? foreground : foregroundLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          color: isDark ? foreground : foregroundLight,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: isDark ? mutedForeground : mutedForegroundLight,
          fontSize: 14,
          height: 1.5,
        ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? card : cardLight,
        selectedItemColor: isDark ?  primaryLight :primary,
        unselectedItemColor: isDark ? mutedForeground : mutedForegroundLight,
        selectedIconTheme: IconThemeData(
          size: 24,
          color: isDark ? primary : primaryLight,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
          color: isDark ? mutedForeground : mutedForegroundLight,
        ),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? primary : primaryLight,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? mutedForeground : mutedForegroundLight,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: true,
      ),
      inputDecorationTheme: _buildInputTheme(isDark: isDark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buildElevatedButtonStyle(isDark: isDark),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buildOutlinedButtonStyle(isDark: isDark),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? primary : primaryLight,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardTheme(
        color: isDark ? card : cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isDark ? border : borderLight,
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? border : borderLight,
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: isDark ? mutedForeground : mutedForegroundLight,
        size: 20,
      ),
    );
  }

  static final ThemeData darkTheme = _buildTheme(isDark: true);
  static final ThemeData lightTheme = _buildTheme(isDark: false);
}
