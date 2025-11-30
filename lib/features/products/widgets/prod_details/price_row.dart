import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/features/products/widgets/trending_badge.dart';

class PriceRow extends ConsumerWidget {
  const PriceRow({super.key, required this.product, required this.isDark});

  final Product product;
  final bool isDark;

  @override
  Widget build(BuildContext context, ref) {
    final priceColor = isDark ? Colors.grey : Colors.grey[700];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            NumberFormat.currency(
              locale: 'en_KE',
              symbol: 'KSH ',
            ).format(product.price),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: priceColor,
            ),
          ),
          // Trending badge
          Consumer(
            builder: (context, ref, _) {
              final views = ref.watch(productViewProvider(product));
              return views > 50
                  ? const SizedBox(child: TrendingBadge())
                  : const SizedBox.shrink();
            },
          ),
          Chip(
            label: Text(product.category, style: const TextStyle(fontSize: 14)),
            backgroundColor: Colors.deepOrange.withAlpha(500),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
