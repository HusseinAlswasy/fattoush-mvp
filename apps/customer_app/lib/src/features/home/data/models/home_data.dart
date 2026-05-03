import 'package:customer_app/src/features/home/data/models/ad_banner.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';

class HomeData {
  const HomeData({
    required this.products,
    required this.ads,
  });

  final List<Product> products;
  final List<AdBannerModel> ads;
}
