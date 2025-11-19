import 'package:flutter/material.dart';
import 'package:kabetex/features/cart/presentations/cart_page.dart';
import 'package:kabetex/features/categories/presentations/categories_page.dart';
import 'package:kabetex/features/home/presentations/home_page.dart';
import 'package:kabetex/features/products/presentation/profile_page.dart';
import 'package:kabetex/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/home/widgets/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          ref.read(tabsProvider.notifier).state = index; // sync Riverpod
        },
      ),

      bottomNavigationBar: MyBottomNav(
        isDarkMode: isDark,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          ref.read(tabsProvider.notifier).state = index; // sync Riverpod
        },
      ),
    );
  }
}
