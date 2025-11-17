import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/nav_bar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MyBottomNav extends ConsumerWidget {
  const MyBottomNav({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context, ref) {
    final selectedIndex = ref.watch(tabsProvider);
    final selectedColor = isDarkMode ? Colors.deepOrange : Colors.deepOrange;
    final unselectedColor = isDarkMode ? Colors.white : Colors.black;

    return SalomonBottomBar(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      currentIndex: selectedIndex,
      onTap: (i) => ref.read(tabsProvider.notifier).state = i,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

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
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              Positioned(
                top: -6,
                left: -6,
                child: Container(
                  height: 16,
                  width: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  constraints: const BoxConstraints(
                    minHeight: 16,
                    minWidth: 16,
                  ),

                  child: Consumer(
                    builder: (context, ref, child) {
                      final cartLength = ref.watch(cartProductsProvider);
                      return Text(
                        cartLength.length.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
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
