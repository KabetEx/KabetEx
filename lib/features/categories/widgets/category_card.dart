import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/categories/presentations/selected_cat_page.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CategoryCard extends ConsumerWidget {
  const CategoryCard({super.key, required this.category});

  final Map<String, dynamic> category;
  @override
  Widget build(BuildContext context, ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600, width: 1.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              SlideRouting(page: SelectedCatPage(category: category)),
            );
          },
          splashColor: Theme.of(context).colorScheme.onPrimary,
          child: SizedBox(
            height: 64,
            width: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(category['path'], height: 60, fit: BoxFit.cover),
                const SizedBox(height: 6),
                Text(
                  category['name'].toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
