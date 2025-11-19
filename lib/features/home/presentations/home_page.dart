import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/home/widgets/app_title_row.dart';
import 'package:kabetex/features/categories/widgets/category_gridview.dart';
import 'package:kabetex/features/home/widgets/hero_banner.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/home/widgets/drawer.dart';
import 'package:kabetex/features/products/widgets/products_listview.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //keeps the homepage alive

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      drawer: const Mydrawer(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              //row for tile and the 2 icons
              const AppTitleRow(),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: [
                    //hero banner
                    const MyHeroBanner(),
                    //gridview for categories
                    const MyCategoryGrid(),
                    //product items gridview
                    const MyProductsGridview(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
