import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = MediaQuery.sizeOf(context).width < 360;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallPhone ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF202A37),
                      child: product.imageUrl == null || product.imageUrl!.isEmpty
                          ? const Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.white70,
                            )
                          : Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                                color: Colors.white70,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallPhone ? 10 : 12),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmallPhone ? 15 : 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3C3F50),
                  ),
                ),
                SizedBox(height: isSmallPhone ? 4 : 6),
                Text(
                  product.description?.isNotEmpty == true
                      ? product.description!
                      : 'Fresh and ready to order',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmallPhone ? 12 : 13,
                    color: Color(0xFF969CB0),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 10 : 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'AED ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isSmallPhone ? 13 : 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5E6BC6),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onAddToCart,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: isSmallPhone ? 34 : 38,
                        height: isSmallPhone ? 34 : 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8B6A),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
