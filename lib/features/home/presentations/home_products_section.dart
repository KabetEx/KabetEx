import 'package:flutter/material.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/widgets/products_listview.dart';
import 'package:kabetex/features/products/widgets/products_shimmer.dart';

class HomeProductsSection extends StatelessWidget {
  const HomeProductsSection({
    super.key,
    required this.isLoading,
    required this.isLoadingMore,
    required this.products,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Products or shimmer
        if (isLoading || products.isEmpty)
          const ProductsShimmer()
        else if (products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "No products yet 😔",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          MyProductsGridview(products: products),

        // Loading more indicator
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
