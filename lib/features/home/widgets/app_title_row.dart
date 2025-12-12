import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/cart/presentations/cart_page.dart';
import 'package:kabetex/features/search/presentation/search_page.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

/// Floating app bar with menu, search, and cart only
class AppTitleSliver extends ConsumerStatefulWidget {
  const AppTitleSliver({super.key});

  @override
  ConsumerState<AppTitleSliver> createState() => _AppTitleSliverState();
}

class _AppTitleSliverState extends ConsumerState<AppTitleSliver> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userByIDProvider(ref.read(currentUserIdProvider)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final cartItems = ref.watch(cartProvider).length;

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      leadingWidth: 80,
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
                isdark: isDarkMode,
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
                    isdark: isDarkMode,
                    background: isDarkMode
                        ? Colors.grey.withAlpha(30)
                        : Colors.grey.withAlpha(100),
                  ),
                  const SizedBox(width: 16),

                  // CART BUTTON
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    ),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.withAlpha(30)
                            : Colors.grey.shade300,
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: asyncProfile.when(
              loading: () {
                return Shimmer.fromColors(
                  key: const ValueKey('loading'),
                  baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[100]!,
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 22,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 22,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
              data: (data) {
                final userName = data?.name.trim().split(' ')[0] ?? '...';
                return SizedBox(
                  child: Column(
                    key: const ValueKey('data'),
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
                  ),
                );
              },
              error: (_, __) => const Text(
                key: ValueKey('error'),
                "Hello ...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
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

  final bool isdark;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.background,
    required this.isdark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        width: 48,
        child: Container(
          decoration: BoxDecoration(
            color: isdark ? Colors.grey.withAlpha(30) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
