import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/home/app_title_row.dart';
import 'package:kabetex/custom%20widgets/home/category_gridview.dart';
import 'package:kabetex/custom%20widgets/theme/gradient_container.dart';
import 'package:kabetex/custom%20widgets/home/hero_banner.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/widgets/drawer.dart';
import 'package:kabetex/custom%20widgets/home/products_listview.dart';

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
        child: const MyGradientContainer(
          child: SafeArea(
            child: Column(
              children: [
                //row for tile and the 2 icons
                AppTitleRow(),
                //hero banner
                MyHeroBanner(),
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
