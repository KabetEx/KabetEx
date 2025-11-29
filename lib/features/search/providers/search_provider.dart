import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:riverpod/legacy.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final _productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});
final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  ref.keepAlive(); // keeps the stream alive when navigating away
  final service = ref.watch(_productServiceProvider);
  return service.getProductsStream();
});

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();

  final streamAsync = ref.watch(productsStreamProvider);

  final products = streamAsync.when(
    data: (data) => data,
    loading: () => <Product>[],
    error: (_, __) => <Product>[],
  );

  if (query.isEmpty) return products;

  return products.where((p) {
    final name = p.title.toLowerCase();
    final desc = p.description.toLowerCase();
    return name.contains(query) || desc.contains(query);
  }).toList();
});
