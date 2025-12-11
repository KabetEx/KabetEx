import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/presentation/tabsScreen.dart';
import 'package:kabetex/features/1community/providers/tabs_provider.dart';
import 'package:kabetex/features/home/presentations/home_products_section.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
import 'package:kabetex/features/home/widgets/app_title_row.dart';
import 'package:kabetex/features/categories/widgets/category_gridview.dart';
import 'package:kabetex/features/home/widgets/hero_banner.dart';
import 'package:kabetex/features/home/widgets/drawer.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'dart:math' as math;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool isRefreshing = false;

  bool showTabBar() {
    final showTabBar = ref.watch(bottomBarVisibleProvider);
    return showTabBar;
  }

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

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showTabBar()) {
          ref.read(bottomBarVisibleProvider.notifier).state = false;
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showTabBar()) {
          ref.read(bottomBarVisibleProvider.notifier).state = true;
        }
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

  void _handleTabTap(int index) async {
    ref.read(homeTopTabProvider.notifier).state = index;

    if (index == 0) {
      ref.read(isLoadingMarketprovider.notifier).state = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        ref.read(isLoadingMarketprovider.notifier).state = false;
      });
    } else if (index == 1) {
      ref.read(isCommunityLoadingProvider.notifier).state = true;
      Future.delayed(const Duration(seconds: 1), () {
        ref.read(isCommunityLoadingProvider.notifier).state = false;
      });
    }

    // reset tabbar visibility when switching tabs
    ref.read(bottomBarVisibleProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = ref.watch(isDarkModeProvider);
    final products = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const Mydrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // ------------------ TABBAR ------------------
              showTabBar()
                  ? AnimatedSlide(
                      offset: showTabBar()
                          ? const Offset(0, 0)
                          : const Offset(0, -1),
                      duration: const Duration(milliseconds: 700),
                      child: AnimatedOpacity(
                        opacity: showTabBar() ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: SizedBox(
                              height: 54,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[900]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: TabBar(
                                  onTap: _handleTabTap,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  dividerHeight: 0,
                                  dividerColor: Colors.transparent,
                                  labelColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                  unselectedLabelColor: Colors.grey[600],
                                  indicator: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  tabs: [
                                    Tab(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Market",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Community",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),

              // ------------------ CONTENT AREA ------------------
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // ------------------ MARKET TAB ------------------
                    RefreshIndicator(
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
                            isLoading:
                                (notifier.isLoading && products.isEmpty) ||
                                isRefreshing,
                            isLoadingMore:
                                notifier.isLoading && products.isNotEmpty,
                            products: products,
                          ),
                        ],
                      ),
                    ),

                    // ------------------ COMMUNITY TAB ------------------
                    Consumer(
                      builder: (context, ref, child) {
                        final isLoadingMkt = ref.watch(isLoadingMarketprovider);

                        if (isLoadingMkt) {
                          return LoadingPage(isDark: isDark);
                        }

                        return const CommunityTabsScreen();
                      },
                    ),
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

// ----------------- LOADING SCREENS -----------------
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key, required this.isDark});

  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? Colors.black.withAlpha(180) : Colors.transparent,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
