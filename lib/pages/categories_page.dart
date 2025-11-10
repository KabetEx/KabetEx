import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/category_card.dart';
import 'package:kabetex/custom%20widgets/gradient_container.dart';
import 'package:kabetex/providers/categories_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allCategories = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All categories')),
      body: MyGradientContainer(
        child: SafeArea(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return CategoryCard(category: allCategories[index]);
            },
          ),
        ),
      ),
    );
  }
}
