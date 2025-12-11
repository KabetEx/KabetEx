import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/cart/presentations/cart_page.dart';
import 'package:kabetex/features/search/presentation/search_page.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';

/// Floating app bar with menu, search, and cart only
class AppTitleSliver extends ConsumerStatefulWidget {
  const AppTitleSliver({super.key});

  @override
  ConsumerState<AppTitleSliver> createState() => _AppTitleSliverState();
}

class _AppTitleSliverState extends ConsumerState<AppTitleSliver> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final cartItems = ref.watch(cartProvider).length;

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      expandedHeight: 64,
      leadingWidth: 70,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //MENU BUTTON
              CircleIconButton(
                icon: Icon(
                  CupertinoIcons.bars,
                  size: 32,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onTap: () => Scaffold.of(context).openDrawer(),
                background: isDarkMode
                    ? Colors.grey.withAlpha(30)
                    : Colors.grey.withAlpha(100),
              ),

              //SEARCH & CART BUTTONS
              Row(
                children: [
                  CircleIconButton(
                    icon: Icon(
                      Icons.search_outlined,
                      size: 28,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                    background: isDarkMode
                        ? Colors.grey.withAlpha(30)
                        : Colors.grey.withAlpha(100),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    ),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.withAlpha(30)
                            : Colors.grey.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Icon(
                              CupertinoIcons.cart,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          if (cartItems > 0)
                            Positioned(
                              right: 0,
                              top: -2,
                              child: Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                  color: Colors.green[800],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    cartItems.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting as a separate sliver
class GreetingSliver extends ConsumerWidget {
  const GreetingSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final userID = ref.watch(currentUserIdProvider);
    final asyncProfile = ref.watch(userByIDProvider(userID));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: asyncProfile.when(
          loading: () => const Text(
            "Hello ...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          data: (data) {
            final userName = data?.name.trim().split(' ')[0] ?? '...';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello $userName",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.deepOrange : Colors.black,
                  ),
                ),
                Text(
                  "Let's shop!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            );
          },
          error: (_, __) => const Text(
            "Hello ...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final Color background;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Center(child: icon),
      ),
    );
  }
}
