import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/custom%20widgets/home/product_card.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/services/product_services.dart';

class MyProductsGridview extends ConsumerStatefulWidget {
  const MyProductsGridview({super.key});

  @override
  ConsumerState<MyProductsGridview> createState() => _MyProductsGridviewState();
}

class _MyProductsGridviewState extends ConsumerState<MyProductsGridview> {
  final productService = ProductService();

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);


    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18),
        child: StreamBuilder(
          stream: productService.productsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final allProducts = (snapshot.data as List)
                .map((map) => Product.fromMap(map))
                .toList();

            final filteredProducts = selectedCategory == 'all'
                ? allProducts
                : allProducts.where((p) {
                    return p.category == selectedCategory;
                  }).toList();

            if (filteredProducts.isEmpty) {
              return const Center(child: Text('No products yet 😔'));
            }

            return MasonryGridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: filteredProducts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
