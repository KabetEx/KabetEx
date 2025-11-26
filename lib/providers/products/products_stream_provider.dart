import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final _productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  ref.keepAlive(); // keeps the stream alive when navigating away
  final service = ref.watch(_productServiceProvider);
  return service.getProductsStream();
});

// ✅ simple non-null cache
final lastProductsCacheProvider = StateProvider<List<Product>>((ref) => []);

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
