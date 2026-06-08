import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:flutter/widgets.dart';

extension AppTextX on BuildContext {
  bool get isArabicText => AppScope.preferencesOf(this).isArabic;

  String tr(String english, String arabic) {
    if (!isArabicText || _looksCorrupted(arabic)) {
      return english;
    }

    return arabic;
  }

  bool _looksCorrupted(String value) {
    return value.contains('Ø') ||
        value.contains('Ù') ||
        value.contains('ð') ||
        value.contains('Ÿ');
  }
}
