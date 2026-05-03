class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    this.category,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final bool isActive;
  final String? category;
  final String? description;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
      category: json['category'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }
}
