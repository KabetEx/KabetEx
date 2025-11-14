import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CartItem extends ConsumerWidget {
  const CartItem({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: Row(
          children: [
            //cover image
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.network(product.imageUrl[0], fit: BoxFit.cover),
            ),

            const SizedBox(width: 16),

            //title and category column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //title
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                //category
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        product.category,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isDarkMode ? Colors.black : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Expanded(child: SizedBox()),

            //price
            Row(
              children: [
                const Text('Kes ', style: TextStyle(color: Colors.white)),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    product.price.toString(),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
