import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MyCategoryGrid extends ConsumerWidget {
  const MyCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allCategories = ref.watch(allCategoriesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 12,
          top: 0,
          bottom: 0,
        ),
        child: Row(
          children: allCategories.map((cat) {
            return GestureDetector(
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = cat['name'];
                print(cat['name']);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        //if selected
                        selectedCategory == cat['name']
                        ? isDarkMode
                              ? Colors.deepOrange
                              : Colors.deepOrange
                        :
                          //if is not selected
                          isDarkMode
                        ? Colors.black
                        : Colors.white,

                    border: Border.all(
                      color: selectedCategory == cat['name']
                          ? Colors.deepOrange
                          : Colors.grey,
                      width: 0.8,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: isDarkMode ? Colors.grey : Colors.black,
                    //     blurRadius: 1,
                    //     offset: const Offset(0.5, 0.5),
                    //   ),
                    // ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: Text(
                    cat['name'].toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color:
                          //if selected
                          selectedCategory == cat['name']
                          ? isDarkMode
                                ? Colors.white
                                : Colors.white
                          //not selected
                          : isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'roboto',
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
