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
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),

                    color:
                        //if selected
                        selectedCategory == cat['name']
                        ? isDarkMode
                              ? Colors.deepOrange
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
                    children: [
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
                          fontSize: 12,
                          fontFamily: 'roboto',
                        ),
                      ),
                      Icon(
                        cat['icon'],
                        color: isDarkMode
                            ? Colors.white
                            : selectedCategory == cat['name']
                            ? Colors.deepOrange
                            : Colors.black,
                      ),
                    ],
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
