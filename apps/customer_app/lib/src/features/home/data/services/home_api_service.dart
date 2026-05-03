import 'package:customer_app/src/core/network/api_client.dart';
import 'package:customer_app/src/features/home/data/models/ad_banner.dart';
import 'package:customer_app/src/features/home/data/models/home_data.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';

class HomeApiService {
  HomeApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<HomeData> fetchHomeData() async {
    final responses = await Future.wait([
      _client.getList('/products'),
      _client.getList('/ads'),
    ]);

    final productList = responses[0]
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
    final adsList = responses[1]
        .map((item) => AdBannerModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return HomeData(products: productList, ads: adsList);
  }
}
