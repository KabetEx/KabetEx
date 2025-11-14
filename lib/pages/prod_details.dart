import 'package:flutter/material.dart';
import 'package:kabetex/custom widgets/gradient_container.dart';
import 'package:kabetex/custom widgets/product_details/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/providers/theme_provider.dart';

class ProdDetailsPage extends ConsumerStatefulWidget {
  const ProdDetailsPage({super.key, required this.product});

  final Product product;
  @override
  ConsumerState<ProdDetailsPage> createState() => _ProdDetailsPageState();
}

class _ProdDetailsPageState extends ConsumerState<ProdDetailsPage> {
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(backgroundColor: isDarkMode ? Colors.grey : Colors.white),
      body: SafeArea(
        child: MyGradientContainer(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                children: [
                  //product gallery
                  const SizedBox(height: 8),
                  ProductGallery(
                    images: widget.product.imageUrl,
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
                            widget.product.name,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 26,
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
                        "Kes ${widget.product.price.toString()}",
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
          ),
        ),
      ),

      bottomNavigationBar: //contact seller
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          height: 70,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            //button
            child: ElevatedButton.icon(
              onPressed: () {},
              label: const Text('Contact seller'),
              icon: const Icon(Icons.chat),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                iconColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
