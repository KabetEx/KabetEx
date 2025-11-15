import 'package:flutter/material.dart';
import 'package:kabetex/custom%20widgets/theme/gradient_container.dart';
import 'package:kabetex/widgets/search_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const MyGradientContainer(
        child: Column(children: [MySearchBar(hint: 'Search products...')]),
      ),
    );
  }
}
