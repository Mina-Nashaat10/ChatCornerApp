import 'package:flutter/material.dart';

class ScreenSize {
  static double getWidthtScreen(BuildContext context) {
    late double widthScreen = MediaQuery.of(context).size.width;
    return widthScreen;
  }

  static double getHeightScreen(BuildContext context) {
    late double heightScreen = MediaQuery.of(context).size.height;
    return heightScreen;
  }
}
