import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/search/search_bar.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      appBar: AppBar(title: const Text('Search')),
      body: const Column(children: [MySearchBar(hint: 'Search products...')]),
    );
  }
}
