import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/features/search/providers/search_provider.dart';
import 'package:kabetex/features/search/widgets/search_bar.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final query = ref.watch(searchQueryProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Search",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // 🔍 Search bar
            const MySearchBar(hint: 'Search for products'),

            // 📊 Results
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        query.isEmpty
                            ? "Start typing to search..."
                            : "No results found 🥲",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : MasonryGridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final p = products[i];
                        return ProductCard(product: p);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
