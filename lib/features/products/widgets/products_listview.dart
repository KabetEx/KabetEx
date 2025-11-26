import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/providers/products/products_stream_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';
// remove: final productService = ProductService();

class MyProductsGridview extends ConsumerWidget {
  const MyProductsGridview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return productsAsync.when(
      loading: () => _buildShimmerGrid(),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (allProducts) {
        final filteredProducts = selectedCategory == 'all'
            ? allProducts
            : allProducts.where((p) {
                return p.category == selectedCategory;
              }).toList();

        if (filteredProducts.isEmpty) {
          return Center(
            child: Text(
              'No products yet 😔',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          );
        }

        return MasonryGridView.count(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: filteredProducts[index]);
          },
        );
      },
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
            baseColor: const Color(0xFFE0E0E0),
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
