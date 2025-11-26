import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/providers/products/products_stream_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

class MyProductsGridview extends ConsumerWidget {
  const MyProductsGridview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityProvider);
    final isOnline = connectivityStatus.maybeWhen(
      data: (value) => value,
      orElse: () => true,
    ); // true/false

    final isDark = ref.watch(isDarkModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allProductsAsync = ref.watch(productsStreamProvider);

    // 1️⃣ Try to use cached data when offline
    // final cachedProducts = allProductsAsync.asData?.value;
    // if (!isOnline && cachedProducts == null) {
    //   final filtered = selectedCategory == 'all'
    //       ? cachedProducts
    //       : cachedProducts!
    //             .where((p) => p.category == selectedCategory)
    //             .toList();

    //   if (filtered!.isEmpty) {
    //     return Center(
    //       child: Text(
    //         'No products yet 😔',
    //         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
    //           color: isDark ? Colors.white : Colors.black,
    //         ),
    //       ),
    //     );
    //   }

    //   return Column(
    //     children: [
    //       Container(
    //         width: double.infinity,
    //         color: Colors.redAccent,
    //         padding: const EdgeInsets.all(8),
    //         child: const Text(
    //           'Offline – showing cached products',
    //           textAlign: TextAlign.center,
    //           style: TextStyle(color: Colors.white),
    //         ),
    //       ),
    //       MasonryGridView.builder(
    //         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
    //           crossAxisCount: 2,
    //         ),
    //         mainAxisSpacing: 8,
    //         crossAxisSpacing: 8,
    //         itemCount: filtered.length,
    //         itemBuilder: (context, index) {
    //           return ProductCard(product: filtered[index]);
    //         },
    //       ),
    //     ],
    //   );
    // }

    return allProductsAsync.when(
      loading: () {
        if (isOnline == false) {
          return _OfflinePlaceholder(
            onRetry: () =>
                ref.invalidate(productsStreamProvider), //refresh stream
          );
        }
        return _buildShimmerGrid();
      },
      error: (err, _) {
        final offline = err is SocketException;
        return _OfflinePlaceholder(
          message: offline
              ? 'No internet connection.\nPlease reconnect and try again.'
              : 'Oops! Couldn’t load products.\nTap retry to try again.', //if online
          onRetry: () => ref.invalidate(productsStreamProvider),
        );
      },
      data: (allProducts) {
        //update cache products when data arrives
        //ref.read(lastProductsCacheProvider.notifier).state = allProducts;
        final filtered = selectedCategory == 'all'
            ? allProducts
            : allProducts.where((p) => p.category == selectedCategory).toList();

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

        return Column(
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
            MasonryGridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return ProductCard(product: filtered[index]);
              },
            ),
          ],
        );
      },
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
            baseColor: const Color.fromARGB(255, 111, 111, 111),
            highlightColor: Colors.grey[300]!,
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
