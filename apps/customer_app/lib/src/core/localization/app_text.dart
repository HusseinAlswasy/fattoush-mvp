import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:flutter/widgets.dart';

extension AppTextX on BuildContext {
  bool get isArabicText => AppScope.preferencesOf(this).isArabic;

  String tr(String english, String arabic) {
    return isArabicText ? arabic : english;
  }
}
