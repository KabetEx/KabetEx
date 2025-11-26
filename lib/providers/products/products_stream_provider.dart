import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';

final _productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsStreamProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  ref.keepAlive(); // keeps the stream alive when navigating away
  final service = ref.watch(_productServiceProvider);
  return service.getProductsStream();
  
});