import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/cart/cart_item.dart';
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
    final cartProducts = ref.watch(cartProductsProvider);
    final totalCart = ref.watch(cartTotalProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);


    return Scaffold(
        backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 16),
                child: Text(
                  'Your cart',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isDarkMode
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartProducts.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(index),
                    onDismissed: (direction) {
                      ref
                          .read(cartProductsProvider.notifier)
                          .deleteFromCart(cartProducts[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Product removed from cart'),
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: 'undo',
                            onPressed: () {
                              ref
                                  .read(cartProductsProvider.notifier)
                                  .addToCart(cartProducts[index]);
                            },
                          ),
                        ),
                      );
                    },
                    child: CartItem(product: cartProducts[index]),
                  );
                },
              ),
            ),
        
            //total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey : Colors.white60,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  Text(
                    'KES $totalCart',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
