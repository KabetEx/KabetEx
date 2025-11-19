import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:shimmer/shimmer.dart';

class MyProductsGridview extends ConsumerStatefulWidget {
  const MyProductsGridview({super.key});

  @override
  ConsumerState<MyProductsGridview> createState() => _MyProductsGridviewState();
}

class _MyProductsGridviewState extends ConsumerState<MyProductsGridview> {
  final productService = ProductService();
  double height = 250;

  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Expanded(
      child: StreamBuilder<List<Product>>(
        stream: productService.getProductsStream(),
        builder: (context, snapshot) {
          //if is still loading data
          if (!snapshot.hasData) {
            return MasonryGridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    // Image shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!, // darker for image
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
                    // Text shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[500]!, // darker for text
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

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allProducts = snapshot.data;

          final filteredProducts = selectedCategory == 'all'
              ? allProducts
              : allProducts!.where((p) {
                  return p.category == selectedCategory;
                }).toList();

          if (filteredProducts!.isEmpty) {
            return const Center(child: Text('No products yet 😔'));
          }

          return MasonryGridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: filteredProducts[index]);
            },
          );
        },
      ),
    );
  }
}
