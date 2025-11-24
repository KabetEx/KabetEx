import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/features/products/widgets/products_listview.dart';
import 'package:kabetex/providers/categories/selected_cat_page_provider.dart';

class SelectedCatPage extends ConsumerStatefulWidget {
  const SelectedCatPage({super.key, required this.category});

  final Map<String, dynamic> category;
  @override
  ConsumerState<SelectedCatPage> createState() => _SelectedCatPageState();
}

class _SelectedCatPageState extends ConsumerState<SelectedCatPage> {
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(
      selectedCategoryProductsProvider(widget.category['name']),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category['name'],
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('Ooops! No products in this category'),
            );
          }
          return MasonryGridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
