import 'package:flutter/material.dart';
import 'package:kabetex/widgets/app_title_row.dart';
import 'package:kabetex/widgets/category_gridview.dart';
import 'package:kabetex/widgets/products_gridview.dart';
import 'package:kabetex/widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              //row for tile and the 2 icons
              AppTitleRow(),
              //search bar
              MySearchBar(hint: 'Search'),
              //gridview for categories
              MyCategoryGrid(),
              //product items gridview
              MyProductsGridview(),
            ],
          ),
        ),
      ),
    );
  }
}
