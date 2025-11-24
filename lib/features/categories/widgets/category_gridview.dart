import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/categories/presentations/categories_page.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MyCategoryGrid extends ConsumerWidget {
  const MyCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allCategories = ref.watch(allCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                ref.read(tabsProvider.notifier).state = 1; // Categories
              },
              child: const Text("View All"),
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: allCategories.take(6).length,
            itemBuilder: (context, index) {
              final cat = allCategories[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      cat['name'];
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 4,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat['name'].toUpperCase() as String,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
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
                        const SizedBox(height: 8),

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
            },
          ),
        ],
      ),
    );
  }
}

        
        
        
        
        
        
        
        
        
        
        
        
//          Row(
//           children: allCategories.map((cat) {
//             return 
//         ),
//       ),
//     );
//   }
// }
