import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({super.key});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool isFavorite = false;
  late final int height;

  final random = Random();

  @override
  void initState() {
    super.initState();
    height = 250 + random.nextInt(30);
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = ref.watch(isDarkModeProvider);

    // Heights between 200 and 250
    return Container(
      height: height.toDouble(),
      decoration: BoxDecoration(
        color: isLightMode ? const Color(0xFF1E1E1E) : Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isLightMode ? Colors.grey : Colors.orange[100]!,
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // main column
          Column(
            children: [
              // image placeholder
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1517336714731-489689fd1ca8',
                  height: height * 0.6,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // texts
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Used Macbook Pc 2020',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isLightMode
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${random.nextInt(5000)}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isLightMode
                              ? Colors.orange
                              : Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // favorite button
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
                scale: isFavorite ? 1.1 : 1.0, // Scale up when favorited
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  isFavorite
                      ? Icons.check_circle_sharp
                      : Icons.add_shopping_cart_sharp,
                  color: !isLightMode
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
    );
  }
}
