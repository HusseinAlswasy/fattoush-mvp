import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ProductImageDataUrl {
  const ProductImageDataUrl._();

  static Future<String> fromXFile(XFile image) async {
    final bytes = await image.readAsBytes();
    final mimeType = _mimeTypeFor(image);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
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
