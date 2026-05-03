import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  // Change this value to your laptop IP when running on a real phone.
  static const String mobileLanHost = '192.168.10.132';
  static const bool useAdbReverseForAndroid = true;

  static String get backendBaseUrl => apiBaseUrl.replaceFirst('/api', '');

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api';
    }

    if (Platform.isAndroid) {
      if (useAdbReverseForAndroid) {
        return 'http://127.0.0.1:3001/api';
      }

      return 'http://$mobileLanHost:3001/api';
    }

    if (Platform.isIOS) {
      return 'http://$mobileLanHost:3001/api';
    }

    return 'http://localhost:3001/api';
  }
}
