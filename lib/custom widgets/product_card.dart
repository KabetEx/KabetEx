import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kabetex/pages/prod_details.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({super.key, required this.product});

  final Product? product;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool isFavorite = false;
  late final double height;
  bool isLoading = true;

  final Random random = Random();

  @override
  void initState() {
    super.initState();

    // Random height for masonry effect
    height =
        250 +
        random.nextInt(60).toDouble(); // variable height for Pinterest style

    //simulate delay
    final randomDelay = 250 + random.nextInt(60);
    // simulate network loading
    Future.delayed(Duration(milliseconds: randomDelay), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    // ---------------- Shimmer ----------------//
    if (isLoading || widget.product == null) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    }

    // ---------------- Real Card ----------------
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProdDetailsPage(product: widget.product!);
            },
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.white12 : Colors.black26,
              blurRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Hero(
                    tag: ValueKey(widget.product!.id),
                    child: CachedNetworkImage(
                      //Thumbnail image
                      imageUrl: widget.product!.imageUrl[1],
                      height: height * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: height * 0.6,
                          width: double.infinity,
                          color: Colors.grey[400],
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/placeholder.png',
                        height: height * 0.6,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Product Name & Price
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product!.name,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product!.price.toString(),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.orange
                                    : Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Favorite Button
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                icon: AnimatedScale(
                  scale: isFavorite ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    isFavorite
                        ? Icons.check_circle_sharp
                        : Icons.add_shopping_cart_sharp,
                    color: !isDarkMode
                        ? isFavorite
                              ? Colors.red
                              : Colors.black
                        : isFavorite
                        ? Colors.red
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
