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

  Future<Product> getProductById(String id) async {
    try {
      final productMap = await service.getProductById(id);
      if (productMap != null) {
        return productMap;
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      print('Error fetching product by ID $e');
      rethrow;
    }
  }

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

final productViewProvider =
    StateNotifierProvider.family<ProductViewNotifier, int, Product>((
      ref,
      product,
    ) {
      return ProductViewNotifier(product);
    });

class ProductViewNotifier extends StateNotifier<int> {
  final Product product;
  final service = ProductService();

  ProductViewNotifier(this.product) : super(product.views);

  // Called once when page opens
  Future<void> increment() async {
    //wait 3 seconds b4 increment views
    await Future.delayed(const Duration(seconds: 3));

    // Local increment first for instant UI feedback
    state = state + 1;

    try {
      // Update DB in background
      final newViews = await service.incrementViews(product.id!, state - 1);
      state = newViews; // sync state with DB
      print(newViews);
    } catch (e) {
      // optional: rollback if needed
      state = state - 1;
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
