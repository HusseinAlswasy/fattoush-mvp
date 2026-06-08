import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ProductImageDataUrl {
  const ProductImageDataUrl._();

  static const int maxDataUrlLength = 350000;

  static Future<String> fromXFile(XFile image) async {
    final bytes = await image.readAsBytes();
    final mimeType = _mimeTypeFor(image);
    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
    if (dataUrl.length > maxDataUrlLength) {
      throw const ProductImageTooLargeException();
    }

    return dataUrl;
  }

  static String _mimeTypeFor(XFile image) {
    final mimeType = image.mimeType;
    if (mimeType != null && mimeType.startsWith('image/')) {
      return mimeType;
    }

    final path = image.path.toLowerCase();
    if (path.endsWith('.png')) {
      return 'image/png';
    }
    if (path.endsWith('.webp')) {
      return 'image/webp';
    }
    if (path.endsWith('.gif')) {
      return 'image/gif';
    }

    return 'image/jpeg';
  }
}

class ProductImageTooLargeException implements Exception {
  const ProductImageTooLargeException();
}
