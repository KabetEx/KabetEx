import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

class CartItem extends ConsumerStatefulWidget {
  const CartItem({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<CartItem> createState() => _CartItemState();
}

class _CartItemState extends ConsumerState<CartItem> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
      child: SizedBox(
        height: 80,
        width: double.infinity,
        child: Row(
          children: [
            //cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.product.imageUrls[1],
                height: 80,
                width: 80,
                // THIS runs whether cached or not:
                progressIndicatorBuilder: (context, url, progress) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 80, width: 80, color: Colors.grey),
                  );
                },
                // error
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 8),

            //collumn
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //title
                  Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  //category & price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              widget.product.category,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      //price
                      Row(
                        children: [
                          Text(
                            'Kes ',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.grey,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.product.price.toString(),
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //price
          ],
        ),
      ),
    );
  }
}
