import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
import 'package:kabetex/features/products/widgets/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ProdDetailsPage extends ConsumerStatefulWidget {
  const ProdDetailsPage({super.key, this.product, this.productId});

  final Product? product;
  final String? productId;

  @override
  ConsumerState<ProdDetailsPage> createState() => _ProdDetailsPageState();
}

class _ProdDetailsPageState extends ConsumerState<ProdDetailsPage> {
  late Product? product;
  bool isLoading = false;
  bool isContacting = false;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    if (product == null && widget.productId != null) {
      fetchProduct(widget.productId!); //fetch product by id
    }
  }

  Future<void> fetchProduct(String id) async {
    setState(() => isLoading = true);
    // fetch from Supabase
    final fetchedProduct = await ProductService().getProductById(id);
    setState(() {
      product = fetchedProduct;
      isLoading = false;
    });
  }

  bool isExisting() {
    final cart = ref.watch(cartProvider);
    return cart.any((p) => p.id == product!.id);
  }

  String formatForWhatsApp(String input) {
    // Remove spaces, dashes, plus signs
    input = input.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 0 → remove it
    if (input.startsWith('0')) {
      input = input.substring(1);
    }

    // If starts with country code already, return
    if (input.startsWith('254')) {
      return input;
    }

    // Otherwise add country code
    return '254$input';
  }

  void contactSeller() async {
    try {
      setState(() => isContacting = true);
      //get seller's number
      final sellerNumber = await ProductService().getSellerNumber(
        product!.sellerId,
      );
      //format number
      final formattedNum = formatForWhatsApp(sellerNumber!);

      if (formattedNum.isEmpty) {
        print("Seller number not available");
        return;
      }
      await openWhatsApp(
        formattedNum,
        "Hey! I found your product '${product!.title}' on Kabetex and I'm interested.",
      );
      setState(() => isContacting = false);
    } catch (e) {
      print('error launching whatsapp');
    } finally {
      setState(() => isContacting = true);
    }
  }

  Future<void> openWhatsApp(String phoneNumber, String message) async {
    final encoded = Uri.encodeComponent(message);

    final deepLink = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=$encoded",
    );
    final webLink = Uri.parse("https://wa.me/$phoneNumber?text=$encoded");

    // Try deep link first (most reliable)
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to web link
    if (await canLaunchUrl(webLink)) {
      await launchUrl(webLink, mode: LaunchMode.externalApplication);
      return;
    }

    print("Could not open WhatsApp");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (product == null) return const Center(child: Text('Product not found'));

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Colors.black
            : const Color.fromARGB(255, 237, 228, 225),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (isExisting()) {
                ref.read(cartProvider.notifier).remove(product!.id!);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item removed from cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item added to cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
                ref
                    .read(cartProvider.notifier)
                    .add(
                      ProductHive(
                        id: product!.id!,
                        title: product!.title,
                        price: product!.price,
                        imageUrl: product!.imageUrls[0],
                        category: product!.category,
                      ),
                    );
              }
            },
            icon: AnimatedScale(
              scale: isExisting() ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                isExisting()
                    ? Icons.check_circle_sharp
                    : Icons.shopping_cart_outlined,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //product gallery
                    ProductGallery(
                      images: product!.imageUrls,
                      product: product!,
                    ),

                    const SizedBox(height: 16),

                    //product title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          product!.title,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: isDarkMode
                                    ? Colors.white
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                fontSize: 24,
                                fontFamily: 'poppins',
                              ),
                        ),
                      ),
                    ),
                    //price
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4,
                        ),
                        child: Text(
                          NumberFormat.currency(
                            locale: 'en_KE',
                            symbol: 'KSH ',
                          ).format(product!.price),
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.deepOrange,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'sans',
                              ),
                        ),
                      ),
                    ),

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
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                                fontFamily: 'sans',
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
                          product!.description,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.grey[800],
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                                fontFamily: 'inter',
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
                  icon: isContacting
                      ? null
                      : const Icon(Icons.chat, color: Colors.white, size: 30),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Contact seller',
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(color: Colors.white, fontSize: 20),
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
      ),
    );
  }
}
