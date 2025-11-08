import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/nav_bar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MyBottomNav extends ConsumerWidget {
  const MyBottomNav({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context, ref) {
    final selectedIndex = ref.watch(tabsProvider);
    final selectedColor = isDarkMode
        ? Colors.orange
        : Theme.of(context).colorScheme.primary;
    final unselectedColor = isDarkMode ? Colors.white : Colors.black;

    return SalomonBottomBar(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 66, 60, 51)
          : Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
      currentIndex: selectedIndex,
      onTap: (i) => ref.read(tabsProvider.notifier).state = i,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home_outlined),
          title: const Text('Home'),
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.grid_view_outlined),
          title: const Text('Categories'),
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.shopping_bag_outlined),
          title: const Text('Cart'),
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
