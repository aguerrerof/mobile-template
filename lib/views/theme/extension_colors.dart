import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/views/theme/custom_colors.dart';
import 'package:mobile_app_template/views/theme/theme_detector.dart';

class MyColors {
  static Color splashBackground =
      ThemeDetector().isDarkMode() ? Color(0xFFFF4101) : Color(0xFFFF4101);
  static Color navBarBackground =
      ThemeDetector().isDarkMode() ? Color(0xFFFF4101) : Color(0xFFFF4101);
  static Color navBarText =
      ThemeDetector().isDarkMode() ? Color(0xFFFDF6E0) : Color(0xFFFDF6E0);
  static Color btnColor =
      ThemeDetector().isDarkMode() ? Color(0xFFFF4101) : Color(0xFFFF4101);
  static Color textBtnColor =
      ThemeDetector().isDarkMode() ? Color(0xFFFDF6E0) : Color(0xFFFDF6E0);

  static Color checkColor =
      ThemeDetector().isDarkMode() ? Color(0xFFFAFAFA) : Color(0xFFFAFAFA);
  static Color checkTextColor =
      ThemeDetector().isDarkMode() ? Color(0xFF212121) : Color(0xFF212121);

  static Color unchekedColor =
      ThemeDetector().isDarkMode() ? backgroundColor : backgroundColor;
  static Color unckekTextColor =
      ThemeDetector().isDarkMode() ? Color(0xFF212121) : Color(0xFF212121);

  static Color borderColor =
      ThemeDetector().isDarkMode() ? Color(0xFF212121) : Color(0xFF212121);
  static Color selectedBorderColor =
      ThemeDetector().isDarkMode() ? Color(0xFFFF4101) : Color(0xFFFF4101);
  static Color titleFocusTextColor =
      ThemeDetector().isDarkMode()
          ? Color.fromARGB(255, 236, 238, 242)
          : Color(0xFF1C47C1);
  static Color cardColor =
      ThemeDetector().isDarkMode() ? backgroundColor : backgroundColor;
  static Color cardSelectedColor =
      ThemeDetector().isDarkMode() ? Color(0xFFFDF6E0) : Color(0xFFFDF6E0);

  static const secondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF1C47C1),
    darkColor: Color(0xFF1C47C1),
  );

  static const Color acentOne = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF6B6B),
    darkColor: Color(0xFFFF6B6B),
  );
  static const Color acentTwo = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF9F43),
    darkColor: Color(0xFFFF9F43),
  );
  static const Color customGray = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFDEE2E6),
    darkColor: Color(0xFFDEE2E6),
  );
  static const Color colorSection = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFEBF4FF),
    darkColor: Color(0xFFEBF4FF),
  );
  static const Color backgroundColor = CupertinoDynamicColor.withBrightness(
    color: CustomColorsTheme.backgroundLight, // Color(0xFFFDF6E0),
    darkColor: CustomColorsTheme.backgroundDark,
  );

  static Color successAlertColor =
      ThemeDetector().isDarkMode() ? Color(0xFFF5E5C0) : Color(0xFFF5E5C0);
  static Color successAlerttextColor =
      ThemeDetector().isDarkMode() ? Color(0xFF4A3B2A) : Color(0xFF4A3B2A);
}

