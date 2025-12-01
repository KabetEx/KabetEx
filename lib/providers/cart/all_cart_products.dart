import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/legacy.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';

// Provider for the cart StateNotifier
final cartProvider = StateNotifierProvider<CartNotifier, List<ProductHive>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<ProductHive>> {
  late Box<ProductHive> _cartBox;

  CartNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    // Open the Hive box
    _cartBox = await Hive.openBox<ProductHive>('cartBox');

    // Initialize state with current Hive values
    state = _cartBox.values.toList();

    // Listen to Hive changes and update state automatically
    _cartBox.listenable().addListener(() {
      state = _cartBox.values.toList();
    });
  }

  /// Add a product to the cart
  void add(ProductHive product) {
    //if product already exists => return
    final exists = _cartBox.values.any((p) => p.id == product.id);

    if (exists) {
      return;
    }

    //else add product
    _cartBox.add(product);

    state = _cartBox.values.toList();
  }

  /// Remove a product from the cart
  void remove(String productId) {
    final matches = _cartBox.values.where((p) => p.id == productId);

    if (matches.isNotEmpty) {
      final target = matches.first;
      target.delete();
    }

    state = _cartBox.values.toList();
  }

  Future<bool> clear() async {
    if (_cartBox.isNotEmpty) {
      await _cartBox.clear();
      state = const [];
      return true;
    } else {
      return false;
    }
  }

  bool exist(String productid) {
    for (final p in state) {
      if (p.id == productid) {
        return true;
      }
    }
    return false;
  }

  double get totalAmount {
    return state.fold<double>(
      0, // initial value
      (total, p) => total + p.price, // add each product price
    );
  }
}
