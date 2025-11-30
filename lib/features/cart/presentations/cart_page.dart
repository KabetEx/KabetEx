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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
            Center(
              child: Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 16),
                child: Text(
                  'Your cart',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartProducts.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(cartProducts[index].id),
                    onDismissed: (direction) async {
                      final deletedProduct = cartProducts[index];

                      // Remove from Hive & Riverpod
                      ref.read(cartProvider.notifier).remove(deletedProduct.id);

                      await showDialog(
                        context: context,

                        builder: (context) => AlertDialog(
                          title: Text(
                            'Item removed',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                          ),
                          content: Text(
                            'Item removed from cart',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                          ),
                          backgroundColor: isDarkMode
                              ? Colors.grey
                              : Colors.black,
                          actions: [
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .add(deletedProduct);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Undo'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: InkWell(
                      splashColor: Colors.grey,
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
