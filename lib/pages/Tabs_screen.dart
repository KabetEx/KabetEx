import 'package:flutter/material.dart';
import 'package:kabetex/pages/cart_page.dart';
import 'package:kabetex/pages/categories_page.dart';
import 'package:kabetex/pages/home_page.dart';
import 'package:kabetex/pages/sellers-section-pages/profile_page.dart';
import 'package:kabetex/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/widgets/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(tabsProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: MyBottomNav(isDarkMode: isDark),
    );
  }
}
