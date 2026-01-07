import 'package:flutter/material.dart';
import '../flavor/flavor_config.dart';

class AppThemes {
  static ThemeData get lightTheme {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.irriBossDevelopment:
        return _irriBossLightTheme;
      case Flavor.irriBossProduction:
        return _irriBossLightTheme;
    }
  }

  static ThemeData get darkTheme {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.irriBossDevelopment:
        return _agritelDarkTheme;
      case Flavor.irriBossProduction:
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



  static const Color appWhiteColor = Colors.white;
  static const Color gradientTopColor = Color(0xFFE6F0FF);
  static const Color gradientMidColor = Color(0xFF67C8F1);
  static const Color gradientBottomColor = Color(0xFF6DA8F5);
  static  Color shadowBlackColor = Colors.black.withValues(alpha: 0.12);

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

  static Color scaffoldBackGround = Color(0xffE1EEEE);

  // Light Theme
  static final ThemeData _irriBossLightTheme = ThemeData(
    scaffoldBackgroundColor: scaffoldBackGround,
    brightness: Brightness.light,
    primarySwatch: primarySwatch,
    primaryColor: primaryColor,
    primaryColorLight: Color(0xff6DA8F5),
    iconTheme: IconThemeData(color: Colors.white),
    colorScheme: ColorScheme.fromSeed(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      background: primarySwatch.shade50,
      error: Colors.red,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: primaryColor.withOpacity(0.1),
      onError: Colors.white,
      seedColor: primaryColor,
    ),
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(
        color: Colors.black
      ),
      backgroundColor: scaffoldBackGround,
      /*foregroundColor: Colors.white,
      elevation: 0,*/
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
      // textColor: Colors.white,
      // titleTextStyle: TextStyle(color: Colors.black, fontSize: 20)
    ),
    textTheme: TextTheme(
     /* titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),*/
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      focusedBorder: UnderlineInputBorder(
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
    ),
    /*checkboxTheme: CheckboxThemeData(
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
    ),*/
    dividerTheme: DividerThemeData(
      color: const Color(0xff727272),
      thickness: 1
    ),


  );
  // Dark Theme
  static final ThemeData _niagaraDarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    /*appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),*/
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
