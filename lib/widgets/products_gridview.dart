import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/widgets/product_card.dart';

class MyProductsGridview extends StatelessWidget {
  const MyProductsGridview({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12),
        child: MasonryGridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: 6,
          itemBuilder: (context, index) {
            return const ProductCard();
          },
        ),
      ),
    );
  }
}
