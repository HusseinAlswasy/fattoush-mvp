import 'package:customer_app/src/features/cart/data/models/cart_item.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:flutter/foundation.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _itemsByProductId = {};

  List<CartItem> get items => _itemsByProductId.values.toList(growable: false);

  int get totalItems => _itemsByProductId.values.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  double get subtotal => _itemsByProductId.values.fold(
        0,
        (sum, item) => sum + item.lineTotal,
      );

  double get deliveryFee => _itemsByProductId.isEmpty
      ? 0
      : subtotal >= 100
          ? 0
          : 10;

  double get total => subtotal + deliveryFee;

  void add(Product product) {
    addMany(product, 1);
  }

  void addMany(Product product, int quantity) {
    if (quantity <= 0) {
      return;
    }

    final existingItem = _itemsByProductId[product.id];
    if (existingItem == null) {
      _itemsByProductId[product.id] = CartItem(product: product, quantity: quantity);
    } else {
      _itemsByProductId[product.id] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    }

    notifyListeners();
  }

  void decrement(Product product) {
    final existingItem = _itemsByProductId[product.id];
    if (existingItem == null) {
      return;
    }

    if (existingItem.quantity <= 1) {
      _itemsByProductId.remove(product.id);
    } else {
      _itemsByProductId[product.id] = existingItem.copyWith(
        quantity: existingItem.quantity - 1,
      );
    }

    notifyListeners();
  }

  void remove(Product product) {
    if (_itemsByProductId.remove(product.id) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_itemsByProductId.isEmpty) {
      return;
    }

    _itemsByProductId.clear();
    notifyListeners();
  }
}
