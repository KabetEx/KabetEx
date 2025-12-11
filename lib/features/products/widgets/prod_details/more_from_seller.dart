import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/providers/seller_provider.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/features/products/widgets/shimmer_grid.dart';

class MoreFromSeller extends ConsumerWidget {
  const MoreFromSeller({
    super.key,
    required this.product,
    required this.isDark,
  });

  final Product product;
  final bool isDark;
  @override
  Widget build(BuildContext context, ref) {
    final sellerProducts = ref.watch(sellerProductsProvider(product.sellerId));
    final sellerProfile = ref.watch(sellerProfileProvider(product.sellerId));
    final sectionHeadingColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        sellerProfile.when(
          data: (profile) {
            String name = profile?.name ?? 'Seller';
            final firstName = name.split(' ').first;

            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'More from ',
                        style: TextStyle(
                          fontFamily: 'Roboto Slab',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: sectionHeadingColor,
                          decorationThickness: 2,
                        ),
                      ),
                      TextSpan(
                        text: firstName,
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                          decorationThickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Loading seller...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          error: (err, st) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Failed to load seller',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),

        const SizedBox(height: 8),
        sellerProducts.when(
          data: (products) {
            if (products == null || products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Nothing here from this seller"),
              );
            }
            return SizedBox(
              height: 265,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductCard(product: p),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const SizedBox(height: 300, child: ShimmerGrid()),
          error: (e, st) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Error loading seller’s products"),
          ),
        ),
      ],
    );
  }
}
