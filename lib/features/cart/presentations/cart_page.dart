import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:kabetex/features/cart/widgets/cart_item.dart';
import 'package:kabetex/features/products/presentation/prod_details.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartProducts = ref.watch(cartProvider);
    final totalCart = ref.watch(cartProvider.notifier).totalAmount;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final formattedTotal = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KES ',
      decimalDigits: 0,
    ).format(totalCart);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your cart',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () async {
                    try {
                      final cleared = await ref
                          .read(cartProvider.notifier)
                          .clear();
                      if (cleared) {
                        SuccessSnackBar.show(
                          context: context,
                          isDark: isDarkMode,
                          message: 'All items removed from cart',
                        );
                      } else {
                        FailureSnackBar.show(
                          context: context,
                          message: 'Nothing to remove 😊',
                          isDark: isDarkMode,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        FailureSnackBar.show(
                          context: context,
                          message: 'Failed to remove items from cart: $e',
                          isDark: isDarkMode,
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.delete_rounded,
                    color: isDarkMode ? Colors.red : Colors.black,
                  ),
                  label: Text(
                    'Delete all',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: cartProducts.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty 🥺',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Lato',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartProducts.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: ValueKey(cartProducts[index].id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            final deletedProduct = cartProducts[index];

                            if (mounted) {
                              SuccessSnackBar.show(
                                context: context,
                                isDark: isDarkMode,
                                message: 'Item removed from cart',
                                label: 'Undo',
                                callback: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .add(deletedProduct);
                                },
                              );
                            }

                            // Remove from Hive & Riverpod
                            ref
                                .read(cartProvider.notifier)
                                .remove(deletedProduct.id);
                          },

                          // 🔥 Custom slide background
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          // 🔥 Slide + Fade animation
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 250),
                            tween: Tween(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(20 * (1 - value), 0),
                                  child: child,
                                ),
                              );
                            },
                            child: InkWell(
                              splashColor: Colors.grey,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProdDetailsPage(
                                      productId: cartProducts[index].id,
                                    ),
                                  ),
                                );
                                // Navigator.push(
                                //   context,
                                //   SlideRouting(
                                //     page: const ProdDetailsShimmer(),
                                //   ),
                                // );
                              },
                              child: CartItem(product: cartProducts[index]),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            //total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
