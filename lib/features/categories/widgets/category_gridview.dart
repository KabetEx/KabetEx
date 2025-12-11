import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/categories/presentations/selected_cat_page.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MyCategoryGrid extends ConsumerWidget {
  const MyCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final allCategories = ref.watch(allCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 2, bottom: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                ref.read(tabsProvider.notifier).state = 1; // Categories
              },
              child: Text(
                "See all",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: allCategories.take(6).length,
            itemBuilder: (context, index) {
              final cat = allCategories[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      SlideRouting(page: SelectedCatPage(category: cat)),
                    );
                  },
                  splashColor: isDarkMode ? Colors.black : Colors.white,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withAlpha(50),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FadeInImage(
                            fadeInDuration: const Duration(milliseconds: 400),
                            placeholder: const AssetImage(
                              'assets/images/placeholder.png',
                            ),
                            image: AssetImage(cat['path']),
                            fit: BoxFit.contain,
                            height: 48,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          cat['name'].toUpperCase() as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                height: 1.5,
                                fontFamily: 'Lato',
                              ),
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
