import 'package:kabetex/dummy%20data/dummy_products.dart';
import 'package:kabetex/models/product.dart';
import 'package:riverpod/legacy.dart';

class DummyProductsNotifier extends StateNotifier<List<Product>> {
  DummyProductsNotifier() : super(dummyProducts);
  //add products

  //delete products
}

final productsProvider =
    StateNotifierProvider<DummyProductsNotifier, List<Product>>(
      (ref) => DummyProductsNotifier(),
    );
