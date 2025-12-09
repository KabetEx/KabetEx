import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/categories/widgets/category_card.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allCategories = ref.watch(allCategoriesProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All categories',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(category: allCategories[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
