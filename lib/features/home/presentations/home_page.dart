import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/home/presentations/home_products_section.dart';
import 'package:kabetex/features/home/widgets/app_title_row.dart';
import 'package:kabetex/features/categories/widgets/category_gridview.dart';
import 'package:kabetex/features/home/widgets/hero_banner.dart';
import 'package:kabetex/features/home/widgets/drawer.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/widgets/products_listview.dart';
import 'package:kabetex/features/products/widgets/products_shimmer.dart';
import 'package:kabetex/providers/theme_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Product> products = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  final int limit = 10;
  final service = ProductService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _scrollController.addListener(() {
      if (!isLoading &&
          !isLoadingMore &&
          hasMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      hasMore = true;
    });
    try {
      final fetched = await service.fetchProducts(limit: limit, offset: 0);
      setState(() {
        products = fetched;
        hasMore = fetched.length == limit;
      });
    } catch (_) {
      print("Error fetching products");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!hasMore) return;

    setState(() => isLoadingMore = true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      final fetched = await service.fetchProducts(
        limit: limit,
        offset: products.length,
      );
      setState(() {
        products.addAll(fetched);
        hasMore = fetched.length == limit;
      });
    } catch (_) {
      print("Error loading more products");
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  Future<void> _refreshProducts() async {
    Future<void> _refreshProducts() async {
  while (isLoading) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  await _loadProducts();
}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

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
                isLoading: isLoading,
                isLoadingMore: isLoadingMore,
                products: products,
              ),
              // const ProductsShimmer(),
            ],
          ),
        ),
      ),
    );
  }
}
