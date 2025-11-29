import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final _productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// FutureProvider for initial load
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final service = ref.watch(_productServiceProvider);
  return service.fetchProducts(limit: 20, offset: 0);
});

// connectivity
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  await for (final result in connectivity.onConnectivityChanged) {
    yield result != ConnectivityResult.none;
  }
});

extension AsyncValueX<T> on AsyncValue<T> {
  bool get isOfflineError => error is SocketException;
}
