import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:flutter/foundation.dart';

class FavoritesController extends ChangeNotifier {
  final Map<String, Product> _productsById = {};

  List<Product> get products => _productsById.values.toList(growable: false);

  int get count => _productsById.length;

  bool isFavorite(Product product) => _productsById.containsKey(product.id);

  void toggle(Product product) {
    if (_productsById.containsKey(product.id)) {
      _productsById.remove(product.id);
    } else {
      _productsById[product.id] = product;
    }

    notifyListeners();
  }

  void remove(Product product) {
    if (_productsById.remove(product.id) != null) {
      notifyListeners();
    }
  }
}
