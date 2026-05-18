import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomColorsTheme {
  // Colores personalizados
  static const Color primaryColor = Color(0xFF007AFF); // Azul iOS
  static const Color secondaryColor = Color(0xFF34C759); // Verde iOS
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFFFFFFF); //FDF5D2
  static const Color textColorLight = Color(0XFF212529);
  static const Color textColorDark = Color(0XFF212529);

  static ThemeData lightMaterialTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: backgroundLight,
    dividerColor: Colors.grey.shade300,
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSurface: Colors.black,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColorLight),
      bodyMedium: TextStyle(color: textColorLight),
      bodySmall: TextStyle(color: textColorLight),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: textColorDark,
      selectionColor: Color(0x33FF4101),
      selectionHandleColor: Color(0xFFFF4101),
    ),
    cardColor: backgroundLight,
  );

  static ThemeData darkMaterialTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: backgroundDark,
    dividerColor: Colors.grey.shade300,
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: secondaryColor,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColorDark),
      bodyMedium: TextStyle(color: textColorDark),
      bodySmall: TextStyle(color: textColorDark),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: textColorDark,
      selectionColor: Color(0x33FF4101),
      selectionHandleColor: Color(0xFFFF4101),
    ),
    cardColor: backgroundDark,
  );

  static CupertinoThemeData lightCupertinoTheme = const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: backgroundLight,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(color: textColorLight),
      actionTextStyle: TextStyle(color: Colors.white),
      navTitleTextStyle: TextStyle(color: Colors.black),
      navLargeTitleTextStyle: TextStyle(color: Colors.black),
    ),
  );

  static CupertinoThemeData darkCupertinoTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: textColorDark,
    scaffoldBackgroundColor: backgroundDark,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        color: textColorDark,
      ), // Color de texto principal en modo oscuro
      actionTextStyle: TextStyle(color: Colors.black),
      navTitleTextStyle: TextStyle(
        color: textColorDark,
      ), // Título de la barra de navegación en modo oscuro
      navLargeTitleTextStyle: TextStyle(
        color: textColorDark,
      ), // Título grande de la barra de navegación en modo oscuro
    ),
  );
}
