import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/utils/slide_routing.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kabetex/pages/product_details/prod_details.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  final Random random = Random();
  late double height;

  @override
  void initState() {
    super.initState();
    // Random height for masonry effect
    height =
        250 +
        random.nextInt(60).toDouble(); // variable height for Pinterest style
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final allCartList = ref.watch(cartProductsProvider);

    // ---------------- Real Card ----------------
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlideRouting(page: ProdDetailsPage(product: widget.product)),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black
              : const Color.fromARGB(255, 237, 228, 225),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.grey[700]! : const Color(0xFF141414),
              blurRadius: 1,
              offset: const Offset(1, 1),
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
                    top: Radius.circular(4),
                  ),
                  child: Hero(
                    tag: ValueKey(widget.product.id),
                    child: CachedNetworkImage(
                      //Thumbnail image
                      imageUrl: widget.product.imageUrls[0],
                      height: height * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 60,
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
                        //product title
                        Text(
                          widget.product.title,
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
                          NumberFormat.currency(
                            locale: 'en_KE',
                            symbol: 'KSh ',
                            decimalDigits: 0,
                          ).format(widget.product.price),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.deepOrange
                                    : Colors.deepOrange,
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
                onPressed: () {},
                icon: AnimatedScale(
                  scale: allCartList.contains(widget.product) ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.check_circle_sharp,
                    color: Colors.red,
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
