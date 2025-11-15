import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/category_card.dart';
import 'package:kabetex/custom%20widgets/theme/gradient_container.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allCategories = ref.watch(allCategoriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: SafeArea(
        child: MyGradientContainer(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(vertical: 16),
                  child: Text(
                    'All categories',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: isDark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(category: allCategories[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
