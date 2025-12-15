import 'package:flutter/material.dart';
import '../flavor/flavor_config.dart';

class AppThemes {
  static ThemeData get lightTheme {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.agritel:
        return _agritelLightTheme;
      case Flavor.niagara:
        return _niagaraLightTheme;
    }
  }

  static ThemeData get darkTheme {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.agritel:
        return _agritelDarkTheme;
      case Flavor.niagara:
        return _niagaraDarkTheme;
    }
  }

  // Agritel Theme Variants
  static final ThemeData _agritelLightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    appBarTheme: AppBarTheme(backgroundColor: Colors.green[600]),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
    ),
  );

  static final ThemeData _agritelDarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(primary: Colors.green),
  );

  // Niagara Theme Variants
  static const Color primaryColor = Color(0xFF016DB5);
  static const Color secondaryColor = Color(0xFF00AFF0);

  // Create a custom swatch for primary color
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0F8AD0,
    <int, Color>{
      50: Color(0xFFE1F2FA),
      100: Color(0xFFB3E5F9),
      200: Color(0xFF81D2F7),
      300: Color(0xFF4FBFF4),
      400: Color(0xFF29B0F2),
      500: Color(0xFF0F8AD0), // Primary
      600: Color(0xFF0D7EC1),
      700: Color(0xFF0A6FAE),
      800: Color(0xFF075F9B),
      900: Color(0xFF03447D),
    },
  );

  // Light Theme
  static final ThemeData _niagaraLightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: primarySwatch,
    primaryColor: primaryColor,
    primaryColorLight: Color(0xff6DA8F5),
    iconTheme: IconThemeData(color: Colors.white),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20)
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(0),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(0),
      ),
      hintStyle: TextStyle(color: Colors.white54),
      labelStyle: TextStyle(color: Colors.white54),
      iconColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        if (states.contains(WidgetState.disabled)) {
          return primaryColor.withOpacity(0.1);
        }
        return Colors.white.withOpacity(0.05);
      }),
      checkColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected) || states.contains(WidgetState.disabled)) {
          return primaryColor;
        }
        return null;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return Colors.white.withOpacity(0.12);
        }
        return null;
      }),
      side: BorderSide(color: Colors.white54, width: 2),
      splashRadius: 24.0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected) || states.contains(WidgetState.disabled)) {
          return primaryColor;
        }
        return Colors.white.withOpacity(0.3);
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white.withOpacity(0.6);
        }
        if (states.contains(WidgetState.disabled)) {
          return primaryColor.withOpacity(0.1);
        }
        return Colors.white.withOpacity(0.1);
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withOpacity(0.06);
        }
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return Colors.white.withOpacity(0.1);
        }
        return Colors.white;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if(states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.white54;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),

  );

  // Dark Theme
  static final ThemeData _niagaraDarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  );
}
