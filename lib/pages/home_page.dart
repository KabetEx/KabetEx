import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/app_title_row.dart';
import 'package:kabetex/custom%20widgets/category_gridview.dart';
import 'package:kabetex/custom%20widgets/hero_banner.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/widgets/drawer.dart';
import 'package:kabetex/widgets/products_listview.dart';
import 'package:kabetex/widgets/search_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 255, 245, 236),
      drawer: const Mydrawer(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 49, 47, 46),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 216, 187, 169),
                    ],
                  ),
          ),
          child: const SafeArea(
            child: Column(
              children: [
                //row for tile and the 2 icons
                AppTitleRow(),
                //hero banner
                MyHeroBanner(),
                //search bar
                MySearchBar(hint: 'Search product'),
                //gridview for categories
                MyCategoryGrid(),
                //product items gridview
                MyProductsGridview(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
