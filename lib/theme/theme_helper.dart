import 'package:flutter/material.dart';
import 'package:Dentepic/core/utils/size_utils.dart';

String _appTheme = "primary";

class ColorSchemes {
  static final primaryColorScheme = ColorScheme.light(
    // Primary colors
    // primary: Color(0XFFFCAB8C), // Light pinkish color
    primary: Colors.transparent, // Light pinkish colo

    onPrimary: Color(0XFFFFFFFF),
    onPrimaryContainer: Color(0XFF444343),
    background: Color(0XFFFFFFFF),
    surface: Color(0XFFFFFFFF),
    error: Color(0XFFB00020),
    onBackground: Color(0XFF000000),
    onSurface: Color(0XFF000000),
    onError: Color(0XFFFFFFFF),
    primaryContainer: Color(0XFFFFC1A3), // Lighter pinkish color
    secondary: Color(0XFFFC947A), // Darker pink color for secondary
    secondaryContainer:
        Color(0XFFFFC1A3), // Light pink color for secondary container
    onSecondary: Color(0XFFFFFFFF),
  );

  static final darkColorScheme = ColorScheme.dark(
    // Primary colors
    primary: Color(0XFFFCAB8C), // Light pinkish color
    onPrimary: Color(0XFF000000),
    onPrimaryContainer: Color(0XFFBBBBBB),
    background: Color(0XFF121212),
    surface: Color(0XFF121212),
    error: Color(0XFFCF6679),
    onBackground: Color(0XFFFFFFFF),
    onSurface: Color(0XFFFFFFFF),
    onError: Color(0XFF000000),
    primaryContainer: Color(0XFF4A4A4A),
    secondary: Color(0XFFFC947A), // Darker pink color for secondary
    secondaryContainer: Color(0XFF121212),
    onSecondary: Color(0XFFFFFFFF),
  );

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCA5B6),
      Color(0xFFEE9367),
    ],
  );
}

/// Helper class for managing themes and colors.
class ThemeHelper {
  // A map of custom color themes supported by the app
  Map<String, PrimaryColors> _supportedCustomColor = {
    'primary': PrimaryColors(),
    'dark': PrimaryColors(),
  };

// A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'primary': ColorSchemes.primaryColorScheme,
    'dark': ColorSchemes.darkColorScheme,
  };

  /// Changes the app theme to [_newTheme].
  void changeTheme(String _newTheme) {
    _appTheme = _newTheme;
  }

  /// Returns the primary colors for the current theme.
  /// Returns the primary colors for the current theme.
  ThemeData getLightThemeData() {
    var colorScheme = ColorSchemes.primaryColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: appTheme.blue50,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(
          width: 1,
        ),
        visualDensity: const VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 3,
        space: 3,
        color: appTheme.teal600,
      ),
    );
  }

  // Dark theme data
  ThemeData getDarkThemeData() {
    var colorScheme = ColorSchemes.darkColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: appTheme.gray900,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(
          width: 1,
        ),
        visualDensity: const VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 3,
        space: 3,
        color: appTheme.teal600,
      ),
    );
  }

  PrimaryColors _getThemeColors() {
    if (!_supportedCustomColor.containsKey(_appTheme)) {
      throw Exception(
          "$_appTheme is not found. Make sure you have added this theme class in JSON. Try running flutter pub run build_runner");
    }
    return _supportedCustomColor[_appTheme] ?? PrimaryColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    if (!_supportedColorScheme.containsKey(_appTheme)) {
      throw Exception(
          "$_appTheme is not found. Make sure you have added this theme class in JSON. Try running flutter pub run build_runner");
    }
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.primaryColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(
          width: 1,
        ),
        visualDensity: const VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 3,
        space: 3,
        color: colorScheme.secondary,
      ),
    );
  }

  /// Returns the primary colors for the current theme.
  PrimaryColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

/// Class containing the supported text theme styles.
class TextThemes {
  static TextTheme textTheme(ColorScheme Colorscheme) => TextTheme(
        bodyLarge: TextStyle(
          color: Colorscheme.onError,
          fontSize: 17.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: appTheme.gray100,
          fontSize: 15.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: appTheme.gray100,
          fontSize: 11.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: appTheme.teal600,
          fontSize: 27.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: appTheme.whiteA700,
          fontSize: 24.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          color: appTheme.gray50,
          fontSize: 12.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: Colorscheme.onError,
          fontSize: 10.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: Colorscheme.errorContainer.withOpacity(1),
          fontSize: 20.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: appTheme.gray100,
          fontSize: 17.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: appTheme.gray100,
          fontSize: 15.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      );
}

class PrimaryColors {
  // Light Theme Colors

  // Black
  Color get black900 => Color(0XFF000000);

  // Blue
  // Color get blue50 => Colors.transparent;
  Color get blue50 => Color(0XFFFCAB8C);


  // BlueGray
  Color get blueGray400 => Color(0XFF8B8B8B);

  // GrayCe
  Color get gray400Ce => Color(0XCEB4B4B4);

  // Gray
  Color get gray500 => Color(0XFF999999);

  // Teal
  Color get teal600 => Color.fromARGB(255, 251, 221, 191);

  // BlueGray
  Color get blueGray100 => Color(0XFFD2D9DA);

  // DeepOrange
  Color get deepOrangeA700 => Color(0XFFE11818);

  // Gray
  Color get gray100 => Color.fromARGB(255, 0, 0, 0);
  Color get gray200 => Color.fromARGB(255, 111, 111, 111);

  // Green
  Color get greenA400 => Color(0XFF0FC87A);
  Color get greenA40001 => Color(0XFF0FC77A);
  Color get gray20002 => Color(0XFFEEEEEE);

  // LightBlue
  Color get lightBlue800 => Color(0XFF198BBB);

  // Teal
  Color get teal400 => Color(0XFFFCAB8C);

  // White
  Color get whiteA700 => Color(0XFFFFFFFF);
  Color get blueGray900 => Color(0XFF353535);
  Color get gray20001 => Color(0XFFEAEAEA);
  Color get gray50 => Color(0XFFFCF8F8);
  Color get gray800 => Color(0XFF444343);
  Color get gray900 => Color(0XFF000000);
  Color get gray400ce => Color(0XCEB444);
  Color get gray9009e => Color(0X9212121);
  Color get limeA200 => Color(0XFFF8FC41);

  // Dark Theme Colors

  // Black
  Color get black900Dark => Color(0XFFFFFFFF); // Adjusted for dark theme
  Color get blue50Dark => Color(0XFF1A1A1A); // Adjusted for dark theme

  // Add more dark theme colors as needed, using similar logic as above...
  // For example:
  Color get blueGray400Dark => Color(0XFF8B8B8B);
  Color get gray500Dark => Color(0XFF666666);
  Color get teal600Dark => Color(0XFF1A5B5D);
  Color get blueGray100Dark => Color(0XFF262626);
  Color get deepOrangeA700Dark => Color(0XFFCC0000);
  Color get gray100Dark => Color(0XFF1C1C1C);
  Color get gray200Dark => Color(0XFF333333);
  Color get greenA400Dark => Color(0XFF0E9A5C);
  Color get lightBlue800Dark => Color(0XFF146586);
  Color get teal400Dark => Color(0XFF2E6F72);
  Color get whiteA700Dark => Color(0XFF121212);
  Color get blueGray900Dark => Color(0XFF1F1F1F);
  Color get gray20001Dark => Color(0XFF2A2A2A);
  Color get gray50Dark => Color(0XFF0D0D0D);
  Color get gray800Dark => Color(0XFF303030);
  Color get gray900Dark => Color(0XFF121212);
  Color get gray400ceDark => Color.fromARGB(206, 123, 122, 122);
  Color get gray9009eDark => Color(0X920E0E0E);
  Color get limeA200Dark => Color(0XFFD4E414);
}

PrimaryColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();
