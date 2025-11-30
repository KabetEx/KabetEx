import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/providers/home/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MyCategoryGrid extends ConsumerWidget {
  const MyCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allCategories = ref.watch(allCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                ref.read(tabsProvider.notifier).state = 1; // Categories
              },
              child: const Text("See all"),
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.1,
            ),
            itemCount: allCategories.take(6).length,
            itemBuilder: (context, index) {
              final cat = allCategories[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      cat['name'];
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        //if selected
                        selectedCategory == cat['name']
                        ? isDarkMode
                              ? Colors.transparent
                              : Colors.transparent
                        :
                          //if is not selected
                          isDarkMode
                        ? Colors.black
                        : Colors.transparent,

                    border: Border.all(
                      color: selectedCategory == cat['name']
                          ? Colors.deepOrange
                          : Colors.grey,
                      width: selectedCategory == cat['name'] ? 1.4 : 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat['icon'],
                        color: isDarkMode
                            ? Colors.white
                            : selectedCategory == cat['name']
                            ? Colors.deepOrange
                            : Colors.black,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'].toUpperCase() as String,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color:
                              //if selected
                              selectedCategory == cat['name']
                              ? isDarkMode
                                    ? Colors.white
                                    : Colors.deepOrange
                              //not selected
                              : isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          height: 1.5,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

        