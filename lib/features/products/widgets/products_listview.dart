import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/features/products/providers/products_stream_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

class MyProductsGridview extends ConsumerStatefulWidget {
  const MyProductsGridview({super.key});

  @override
  ConsumerState<MyProductsGridview> createState() => _MyProductsGridviewState();
}

class _MyProductsGridviewState extends ConsumerState<MyProductsGridview> {
  List<Product> products = [];
  int offset = 0;
  final int limit = 20;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final service = ProductService();

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        _loadMoreProducts();
      }
    });
  }

  Future<void> _loadInitialProducts() async {
    setState(() => isLoading = true);
    try {
      final fetched = await service.fetchProducts(limit: limit, offset: 0);
      setState(() {
        products = fetched;
        offset = fetched.length;
        hasMore = fetched.length == limit;
      });
    } catch (e) {
      // handle error if needed
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreProducts() async {
    setState(() => isLoadingMore = true);
    final fetched = await service.fetchProducts(limit: limit, offset: offset);
    setState(() {
      products.addAll(fetched);
      offset += fetched.length;
      isLoadingMore = false;
      hasMore = fetched.length == limit;
    });
  }

  Future<void> _refreshProducts() async {
    final service = ProductService();
    final fetched = await service.fetchProducts(limit: limit, offset: 0);
    setState(() {
      products = fetched;
      offset = fetched.length;
      hasMore = fetched.length == limit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityStatus = ref.watch(connectivityProvider);
    final isOnline = connectivityStatus.maybeWhen(
      data: (value) => value,
      orElse: () => true,
    ); // true/false

    final isDark = ref.watch(isDarkModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    if (isLoading) {
      if (!isOnline) {
        return _OfflinePlaceholder(onRetry: _loadInitialProducts);
      }
      return _buildShimmerGrid();
    }

    final filtered = selectedCategory == 'all'
        ? products
        : products.where((p) => p == selectedCategory).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No products yet 😔',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Column(
        children: [
          if (!isOnline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Offline – showing cached products',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          Expanded(
            child: MasonryGridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: filtered.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return ProductCard(product: filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflinePlaceholder extends StatelessWidget {
  const _OfflinePlaceholder({
    this.message = 'You’re offline. Please check your connection.',
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

Widget _buildShimmerGrid() {
  const height = 250.0;

  return MasonryGridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    shrinkWrap: true,
    physics: const BouncingScrollPhysics(),
    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    itemCount: 4,
    itemBuilder: (context, index) {
      return Column(
        children: [
          Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 163, 163, 163),
            highlightColor: const Color.fromARGB(255, 139, 139, 139),
            child: Container(
              height: height * 0.6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[500]!,
                  highlightColor: Colors.grey[350]!,
                  child: Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[500]!,
                  highlightColor: Colors.grey[350]!,
                  child: Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
