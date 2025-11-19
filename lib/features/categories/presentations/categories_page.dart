import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/categories/widgets/category_card.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allCategories = ref.watch(allCategoriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      body: SafeArea(
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
    );
  }
}
