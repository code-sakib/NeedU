import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double defaultIconSize;
  static late double iconLarge;
  static late double iconMedium;

  // Call this in main app (or first screen)
  void init(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    blockWidth = screenWidth / 100;   // 1% of screen width
    blockHeight = screenHeight / 100; // 1% of screen height
    defaultIconSize = blockHeight * 0.05; // Default icon size based on block height
    iconMedium = blockHeight * 3; // Medium icon size (2% of screen height)
    iconLarge = blockHeight * 5; // Large icon size (5% of screen height)
  }
}
