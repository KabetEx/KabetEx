import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/custom%20widgets/home/product_card.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/products_provider.dart';
import 'package:kabetex/providers/categories/selected_category.dart';

class MyProductsGridview extends ConsumerWidget {
  const MyProductsGridview({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final products = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    List<Product> getProductsByCat() {
      List<Product> filteredProducts;

      if (selectedCategory == 'all') {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((p) {
          return p.category == selectedCategory;
        }).toList();
      }

      return filteredProducts;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18),
        child: MasonryGridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: getProductsByCat().length,
          itemBuilder: (context, index) {
            return ProductCard(product: getProductsByCat()[index]);
          },
        ),
      ),
    );
  }
}
