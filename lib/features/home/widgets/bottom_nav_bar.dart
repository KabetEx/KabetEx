import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MyBottomNav extends ConsumerWidget {
  const MyBottomNav({super.key, required this.isDarkMode, required this.onTap});

  final bool isDarkMode;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context, ref) {
    final selectedIndex = ref.watch(tabsProvider);
    final selectedColor = isDarkMode ? Colors.deepOrange : Colors.deepOrange;
    final unselectedColor = isDarkMode ? Colors.white : Colors.black;

    return SalomonBottomBar(
      duration: const Duration(milliseconds: 1000),
      backgroundColor: Colors.transparent,
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(tabsProvider.notifier).state = index;
        onTap(index); // pass the selectedIndex to parent widget
      },
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home_outlined, size: 24),
          title: const Text('Home'),
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
        ),

        SalomonBottomBarItem(
          icon: const Icon(CupertinoIcons.group_solid, size: 24),
          title: Text(
            'Community',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
        ),

        SalomonBottomBarItem(
          icon: const Icon(Icons.account_circle_outlined),
          title: const Text('Profile'),
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
        ),
      ],
    );
  }
}
