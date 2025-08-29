import 'package:flutter/widgets.dart';
import 'package:needu/core/app_theme.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double defaultIconSize;
  static late double iconLarge;
  static late double iconMedium;

  static late double paddingSmall;
  static late double  paddingMedium;
  static late double paddingLarge;
  // Padding for the main content area
  static late double screenVPadding;
  static late double screenHPadding;

  static late double defaultHeight1;
  static late double defaultHeight2;

  static TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  // Call this in main app (or first screen)
  void init(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    blockWidth = screenWidth / 100; // 1% of screen width
    blockHeight = screenHeight / 100; // 1% of screen height
    defaultIconSize =
        blockHeight * 0.05; // Default icon size based on block height
    iconMedium = blockHeight * 3; // Medium icon size (2% of screen height)
    iconLarge = blockHeight * 5; // Large icon size (5% of screen height)
    paddingSmall = blockHeight * 2; // Small padding (0.5% of screen height)
    paddingMedium = blockHeight * 6; // Medium padding (1% of screen height)
    paddingLarge = blockHeight * 9; // Large padding (2% of screen height
    screenVPadding = blockHeight * 2; // Main content padding (3% of screen height)
    screenHPadding = blockWidth * 4; // Main content padding (4% of screen width)
    defaultHeight1 = blockHeight * 6; // Default difference between heights for elements
    defaultHeight2 = blockHeight * 3; // Default difference between heights for elements
  }
}
