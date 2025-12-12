import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/home/presentations/home_products_section.dart';
import 'package:kabetex/features/home/widgets/app_title_row.dart';
import 'package:kabetex/features/categories/widgets/category_gridview.dart';
import 'package:kabetex/features/home/widgets/hero_banner.dart';
import 'package:kabetex/features/home/widgets/drawer.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/features/products/widgets/products_shimmer.dart';
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
    // Initial products load
    Future.microtask(() => ref.read(productsProvider.notifier).loadProducts());

    //load more products
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

    while (notifier.isLoading) {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await notifier.loadProducts();
    setState(() => isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = ref.watch(isDarkModeProvider);
    final products = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);

    return Scaffold(
      drawer: const Mydrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: isDark ? Colors.black : Colors.white,
          color: Colors.deepOrange,
          onRefresh: _refreshProducts,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),

            slivers: [
              // Sticky app title row
              const AppTitleSliver(),

              const GreetingSliver(),
              // Hero banner
              const SliverToBoxAdapter(child: MyHeroBanner()),

              // Categories
              const SliverToBoxAdapter(child: MyCategoryGrid()),

              // Products or shimmer
              products.isEmpty && notifier.isLoading
                  ? const SliverToBoxAdapter(child: ProductsShimmer())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) { 
                        return HomeProductsSection(
                          products: products,
                          isLoading: false,
                          isLoadingMore: false,
                        );
                      }, childCount: products.length),
                    ),

              // Loading more indicator at bottom
              if (notifier.isLoading && products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
