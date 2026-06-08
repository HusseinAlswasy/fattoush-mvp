import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  // Change this value to your laptop IP when running on a real phone without adb reverse.
  static const String productionApiUrl = 'https://fattoush-mvp.vercel.app/api';
  static const String mobileLanHost = '192.168.0.142';
  static const bool useAdbReverseForAndroid = true;
  static const List<int> apiPorts = [3000];

  static String get backendBaseUrl => apiBaseUrl.replaceFirst('/api', '');

  static List<String> get apiBaseUrls {
    if (kIsWeb) {
      return [
        productionApiUrl,
        ...apiPorts
            .map((port) => 'http://localhost:$port/api')
            .followedBy(apiPorts.map((port) => 'http://127.0.0.1:$port/api')),
      ];
    }

    if (Platform.isAndroid) {
      final localCandidates =
          apiPorts.map((port) => 'http://127.0.0.1:$port/api');
      final lanCandidates =
          apiPorts.map((port) => 'http://$mobileLanHost:$port/api');
      if (useAdbReverseForAndroid) {
        return [productionApiUrl, ...localCandidates, ...lanCandidates];
      }

      return [productionApiUrl, ...lanCandidates, ...localCandidates];
    }

    if (Platform.isIOS) {
      return [
        productionApiUrl,
        ...apiPorts.map((port) => 'http://$mobileLanHost:$port/api'),
      ];
    }

    return [
      productionApiUrl,
      ...apiPorts.map((port) => 'http://localhost:$port/api'),
    ];
  }

  static String get apiBaseUrl {
    final urls = apiBaseUrls;
    if (urls.isNotEmpty) {
      return urls.first;
    }

    return 'http://localhost:3000/api';
  }
}
