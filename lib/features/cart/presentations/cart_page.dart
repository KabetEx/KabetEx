import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                    key: ValueKey(cartProducts[index].id),
                    onDismissed: (direction) {
                      final deletedProduct = cartProducts[index];

                      // Remove from Hive & Riverpod
                      ref.read(cartProvider.notifier).remove(deletedProduct.id);

                      // Show SnackBar safely
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: const Text('Item removed from cart'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Undo logic
                                ref
                                    .read(cartProvider.notifier)
                                    .add(deletedProduct);
                              },
                            ),
                          ),
                        );
                    },
                    child: InkWell(
                      splashColor: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProdDetailsPage(
                              productId: cartProducts[index].id, // pass just id
                            ),
                          ),
                        );
                      },
                      child: CartItem(product: cartProducts[index]),
                    ),
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
                    formattedTotal,
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
