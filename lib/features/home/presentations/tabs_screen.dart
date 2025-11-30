import 'package:flutter/material.dart';
import 'package:kabetex/features/cart/presentations/cart_page.dart';
import 'package:kabetex/features/categories/presentations/categories_page.dart';
import 'package:kabetex/features/home/presentations/home_page.dart';
import 'package:kabetex/features/profile/presentantion/profile_page.dart';
import 'package:kabetex/providers/home/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/home/widgets/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabsProvider);
    final isDark = ref.watch(isDarkModeProvider);

    final pages = [
      const HomePage(),
      const CategoriesPage(),
      const CartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: MyBottomNav(
        isDarkMode: isDark,
        onTap: (index) {
          ref.read(tabsProvider.notifier).state = index;
        },
      ),
    );
  }
}
