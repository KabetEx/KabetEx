import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/legacy.dart';

final productsProvider =
    StateNotifierProvider<ProductListNotifier, List<Product>>((ref) {
      return ProductListNotifier();
    });

class ProductListNotifier extends StateNotifier<List<Product>> {
  ProductListNotifier() : super([]);
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 10;
  final service = ProductService();

  Future<void> loadProducts() async {
    if (isLoading) return;
    isLoading = true;
    try {
      final fetched = await service.fetchProducts(limit: limit, offset: 0);
      state = fetched;
      hasMore = fetched.length == limit;
    } catch (e) {
      print('Error loading products $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoading) return;
    isLoading = true;
    try {
      final fetched = await service.fetchProducts(
        limit: limit,
        offset: state.length,
      );
      state = [...state, ...fetched];
      hasMore = fetched.length == limit;
    } catch (e) {
      print('Error loading more products $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }
}

// Connectivity StreamProvider
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  await for (final result in connectivity.onConnectivityChanged) {
    yield result != ConnectivityResult.none;
  }
});

// Helper extension
extension AsyncValueX<T> on AsyncValue<T> {
  bool get isOfflineError => error is SocketException;
}
