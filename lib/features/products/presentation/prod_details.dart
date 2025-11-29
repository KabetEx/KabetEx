import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/providers/seller_provider.dart';
import 'package:kabetex/features/products/widgets/contact_button.dart';
import 'package:kabetex/features/products/widgets/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/features/products/widgets/seller_card.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  final _productService = ProductService();
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    product = widget.product;

    if (product == null && widget.productId != null) {
      fetchProduct(widget.productId!);
    }

    // _loadSellerInfo();
  }

  Future<void> fetchProduct(String id) async {
    setState(() => isLoading = true);
    final fetchedProduct = await ProductService().getProductById(id);
    if (!mounted) return;

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
      final sellerProfile = await ref.read(
        sellerProfileProvider(product!.sellerId).future,
      );
      final sellerNumber = sellerProfile?['phone_number'];
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

  void _showReportDialog(BuildContext context) {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please select a reason:'),
                const SizedBox(height: 12),
                ...[
                  'Spam',
                  'Inappropriate content',
                  'Fake product',
                  'Wrong category',
                  'Other',
                ].map(
                  (reason) => InkWell(
                    onTap: () {
                      setState(() => selectedReason = reason);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedReason == reason
                                    ? Colors.deepOrange
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: selectedReason == reason
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      report(selectedReason!);
                    },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void report(String selectedReason) async {
    try {
      await _productService.reportProduct(
        product!.id!,
        product!.sellerId,
        selectedReason,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reported: $selectedReason'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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

    final isAvailable = product!.isActive ?? true;

    final sellerProducts = ref.watch(sellerProductsProvider(product!.sellerId));
    final sellerProfile = ref.watch(sellerProfileProvider(product!.sellerId));

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(
                isAvailable ? 'Available' : 'Unavailable',
                style: const TextStyle(fontSize: 12),
              ),
              side: const BorderSide(color: Colors.transparent),
              backgroundColor: isAvailable ? Colors.green : Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
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
                color: Colors.green,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Report product'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SizedBox.expand(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductGallery(
                      images: product!.imageUrls,
                      product: product!,
                    ),
                    const SizedBox(height: 16),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
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
                          Chip(
                            label: Text(
                              product!.category,
                              style: const TextStyle(fontSize: 14),
                            ),
                            backgroundColor: Colors.deepOrange.withAlpha(200),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SellerCard(
                      isDark: isDarkMode,
                      sellerId: widget.product!.sellerId,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Roboto Slab',
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: sectionHeadingColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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

                    // MORE FROM SELLER section header
                    sellerProfile.when(
                      data: (profile) {
                        String name = profile?['full_name'] ?? 'Guest';
                        final firstName = name.split(' ').first;

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'More from ',
                                    style: TextStyle(
                                      fontFamily: 'Roboto Slab',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: sectionHeadingColor,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: firstName,
                                    style: const TextStyle(
                                      fontFamily: 'Sans',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      decorationThickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Loading seller...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      error: (err, st) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Failed to load seller',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    sellerProducts.when(
                      data: (products) {
                        if (products == null || products.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("Nothing here from this seller"),
                          );
                        }
                        return SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final p = products[index];
                                return SizedBox(
                                  width: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ProductCard(product: p),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      loading: () =>
                          SizedBox(height: 300, child: _buildShimmerGrid()),
                      error: (e, st) => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Error loading seller’s products"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ContactButton(
            isAvailable: isAvailable,
            isContacting: isContacting,
            contactSeller: contactSeller,
          ),
        ],
      ),
    );
  }
}

// ===========================
// SHIMMER LOADER
// ===========================
Widget _buildShimmerGrid() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // product image shimmer
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 170, 170, 170),
                highlightColor: const Color.fromARGB(255, 210, 210, 210),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // title shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                child: Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // price shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                child: Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
