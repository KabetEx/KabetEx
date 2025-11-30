import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/home/presentations/home_products_section.dart';
import 'package:kabetex/features/home/widgets/app_title_row.dart';
import 'package:kabetex/features/categories/widgets/category_gridview.dart';
import 'package:kabetex/features/home/widgets/hero_banner.dart';
import 'package:kabetex/features/home/widgets/drawer.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // Load products once at start
    Future.microtask(() => ref.read(productsProvider.notifier).loadProducts());

    _scrollController.addListener(() {
      final notifier = ref.read(productsProvider.notifier);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          notifier.hasMore &&
          !notifier.isLoading &&
          !isRefreshing) {
        notifier.loadMore();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    final notifier = ref.read(productsProvider.notifier);

    setState(() => isRefreshing = true);
    // wait first for load b4 reload
    while (notifier.isLoading) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    await ref.read(productsProvider.notifier).loadProducts();
    setState(() => isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = ref.watch(isDarkModeProvider);
    final productsState = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);

    return Scaffold(
      drawer: const Mydrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: isDark ? Colors.black : Colors.white,
          color: Colors.deepOrange,
          onRefresh: _refreshProducts,
          child: ListView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              const AppTitleRow(),
              const SizedBox(height: 8),
              const MyHeroBanner(),
              const MyCategoryGrid(),

              HomeProductsSection(
                // Show shimmer during initial load OR refresh
                isLoading:
                    (notifier.isLoading && productsState.isEmpty) ||
                    isRefreshing,
                isLoadingMore: notifier.isLoading && productsState.isNotEmpty,
                products: productsState,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
