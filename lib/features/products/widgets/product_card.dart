import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/products/presentation/prod_details.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  late double randomHeight;
  bool isExisting() {
    final cart = ref.watch(cartProvider);
    return cart.any((p) => p.id == widget.product.id);
  }

  @override
  void initState() {
    super.initState();
    randomHeight = (200 + Random().nextInt(60)).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              SlideRouting(page: ProdDetailsPage(product: widget.product)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrls[0],
                        width: double.infinity,
                        height: randomHeight * 0.6,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Product info
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "KSh ${widget.product.price.toStringAsFixed(0)}",
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32), // space for button
                  ],
                ),

                // Add to cart button
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: IconButton(
                    onPressed: () {
                      if (isExisting()) {
                        ref
                            .read(cartProvider.notifier)
                            .remove(widget.product.id!);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item removed from cart'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item added to cart'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        ref
                            .read(cartProvider.notifier)
                            .add(
                              ProductHive(
                                id: widget.product.id!,
                                title: widget.product.title,
                                price: widget.product.price,
                                imageUrl: widget.product.imageUrls[0],
                                category: widget.product.category,
                              ),
                            );
                      }
                    }, // handle add/remove cart
                    icon: isExisting()
                        ? Icon(
                            Icons.check_circle_sharp,
                            color: isDarkMode ? Colors.white : Colors.green,
                          )
                        : Icon(
                            Icons.shopping_cart_outlined,
                            color: isDarkMode
                                ? Colors.white
                                : const Color.fromARGB(255, 97, 97, 97),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
