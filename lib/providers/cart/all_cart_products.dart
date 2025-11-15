import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';
import 'package:riverpod/legacy.dart';

class CartProducts extends StateNotifier<List<Product>> {
  CartProducts() : super([]);

  //add cart items
  void addToCart(Product product) {
    state = [product, ...state];
  }

  //delete cart items
  void deleteFromCart(Product product) {
    state = state.where((p) {
      return p.id != product.id;
    }).toList();
  }
}

final cartProductsProvider = StateNotifierProvider<CartProducts, List<Product>>(
  (ref) {
    return CartProducts();
  },
);

//get total cart amount
final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProductsProvider);
  return cartItems.fold(0.0, (sum, item) => sum + item.price);
});
