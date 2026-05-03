import 'package:flutter/material.dart';

extension AppResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isSmallPhone => screenWidth < 360;

  bool get isCompactHeight => screenHeight < 700;

  double responsive({
    required double small,
    required double medium,
    double? large,
  }) {
    if (screenWidth < 360) {
      return small;
    }
    if (screenWidth < 430) {
      return medium;
    }
    return large ?? medium;
  }
}
