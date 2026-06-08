import 'package:flutter/material.dart';

class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.shopping_basket_rounded,
    this.fallbackIconColor = const Color(0xFFFF5A52),
    this.fallbackBackground = const Color(0xFFFFEEE8),
  });

  final String? imageUrl;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final Color fallbackBackground;

  @override
  Widget build(BuildContext context) {
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) {
      return _FallbackImage(
        icon: fallbackIcon,
        iconColor: fallbackIconColor,
        background: fallbackBackground,
      );
    }

    if (value.startsWith('data:image')) {
      try {
        return Image.memory(
          UriData.parse(value).contentAsBytes(),
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _FallbackImage(
            icon: fallbackIcon,
            iconColor: fallbackIconColor,
            background: fallbackBackground,
          ),
        );
      } catch (_) {
        return _FallbackImage(
          icon: fallbackIcon,
          iconColor: fallbackIconColor,
          background: fallbackBackground,
        );
      }
    }

    return Image.network(
      value,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _FallbackImage(
        icon: fallbackIcon,
        iconColor: fallbackIconColor,
        background: fallbackBackground,
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage({
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: iconColor,
        size: 42,
      ),
    );
  }
}
