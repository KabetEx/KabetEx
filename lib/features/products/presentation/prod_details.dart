import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/products/widgets/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/products/data/product_services.dart';

class ProdDetailsPage extends ConsumerStatefulWidget {
  const ProdDetailsPage({super.key, required this.product});

  final Product product;
  @override
  ConsumerState<ProdDetailsPage> createState() => _ProdDetailsPageState();
}

class _ProdDetailsPageState extends ConsumerState<ProdDetailsPage> {
  bool isAdded = false;
  final productServive = ProductService();

  void contactSeller() async {
    final sellerNumber = await productServive.getSellerNumber(
      widget.product.sellerId,
    );

    print(sellerNumber);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      appBar: AppBar(backgroundColor: isDarkMode ? Colors.grey : Colors.white),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                children: [
                  //product gallery
                  ProductGallery(
                    images: widget.product.imageUrls,
                    product: widget.product,
                  ),

                  const SizedBox(height: 16),

                  //product title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        //title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.product.title,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 26,
                                  overflow: TextOverflow.visible,
                                ),
                          ),
                        ),

                        const Spacer(),

                        //add to cart
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isAdded = !isAdded;
                            });
                          },
                          icon: AnimatedScale(
                            scale: isAdded ? 1.3 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.bounceIn,
                            child: isAdded
                                ? const Icon(
                                    Icons.shopping_cart_checkout,
                                    size: 24,
                                    color: Colors.black,
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                          ),
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                  //price
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Text(
                        NumberFormat.currency(
                          locale: 'en_KE',
                          symbol: 'KSh ',
                        ).format(widget.product.price),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  //product description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Text(
                        widget.product.description,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Positioned(
              bottom: 16, // distance from bottom
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: contactSeller,
                icon: const Icon(Icons.chat, color: Colors.white, size: 30),
                label: Text(
                  'Contact seller',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 6, // shadow for floating effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
