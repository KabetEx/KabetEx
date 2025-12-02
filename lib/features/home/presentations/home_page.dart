import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/presentation/feedPage.dart';
import 'package:kabetex/features/1community/presentation/tabsScreen.dart';
import 'package:kabetex/features/home/presentations/home_products_section.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const Mydrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // TOP TAB BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: // inside HomePage
                TabBar(
                  onTap: (index) {
                    ref.read(homeTopTabProvider.notifier).state = index;

                    if (index == 1) {
                      // Community tab
                      ref.read(isCommunityLoadingProvider.notifier).state =
                          true;

                      // simulate fetch
                      Future.delayed(const Duration(seconds: 1), () {
                        ref.read(isCommunityLoadingProvider.notifier).state =
                            false;
                      });
                    }
                  },
                  labelColor: Colors.black, // active tab text
                  unselectedLabelColor: Colors.grey[600], // inactive tab text
                  indicatorColor: Colors.deepOrange, // underline color
                  indicatorWeight: 3, // thickness of underline
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // like X
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700, // bold active tab
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // slightly lighter inactive
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ), // no ripple at all
                  tabs: const [
                    Tab(text: "Market"),
                    Tab(text: "Community"),
                  ],
                ),
              ),

              // CONTENT AREA
              Expanded(
                child: TabBarView(
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
                        final isLoading = ref.watch(isCommunityLoadingProvider);

                        if (isLoading) {
                          return const LoadingCommunityPage();
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

class LoadingCommunityPage extends StatelessWidget {
  const LoadingCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6F00),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/kabetex.png', height: 250, width: 250),
          Center(
            child: Text(
              'Loading Community...',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
