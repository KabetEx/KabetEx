import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/widgets/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
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
      fetchProduct(widget.productId!);
    }
  }

  Future<void> fetchProduct(String id) async {
    setState(() => isLoading = true);
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
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('0')) input = input.substring(1);
    if (input.startsWith('254')) return input;
    return '254$input';
  }

  void contactSeller() async {
    setState(() => isContacting = true);
    try {
      final sellerNumber = await ProductService().getSellerNumber(
        product!.sellerId,
      );
      if (sellerNumber == null) return;

      final formattedNum = formatForWhatsApp(sellerNumber);
      await openWhatsApp(
        formattedNum,
        "Hey! I found your product '${product!.title}' on Kabetex and I'm interested.",
      );
    } catch (e) {
      print('Error contacting seller: $e');
    } finally {
      setState(() => isContacting = false);
    }
  }

  Future<void> openWhatsApp(String phoneNumber, String message) async {
    final encoded = Uri.encodeComponent(message);
    final deepLink = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=$encoded",
    );
    final webLink = Uri.parse("https://wa.me/$phoneNumber?text=$encoded");

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webLink)) {
      await launchUrl(webLink, mode: LaunchMode.externalApplication);
      return;
    }

    print("Could not open WhatsApp");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final priceColor = isDarkMode ? Colors.grey : Colors.deepOrange;
    final descColor = isDarkMode ? Colors.white70 : Colors.grey[800];
    final sectionHeadingColor = isDarkMode ? Colors.white : Colors.black87;

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item removed from cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item added to cart'),
                    duration: Duration(seconds: 1),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductGallery(
                      images: product!.imageUrls,
                      product: product!,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        product!.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        NumberFormat.currency(
                          locale: 'en_KE',
                          symbol: 'KSH ',
                        ).format(product!.price),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: priceColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description heading
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Roboto Slab',
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: sectionHeadingColor,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        product!.description,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: descColor,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Floating Contact Button
              Positioned(
                bottom: 8,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: isContacting ? null : contactSeller,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isContacting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Contact Seller',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
