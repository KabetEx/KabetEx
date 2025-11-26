import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/widgets/contact_button.dart';
import 'package:kabetex/features/products/widgets/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/widgets/seller_card.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
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
  String? sellerId;
  String? sellerName;
  String? sellerNumber;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    if (product == null && widget.productId != null) {
      fetchProduct(widget.productId!);
    } else if (product != null) {
      // ✅ only load profile if product already exists
      _loadSellerProfile();
    }
  }

  //fetch product with id
  Future<void> fetchProduct(String id) async {
    setState(() => isLoading = true);
    final fetchedProduct = await ProductService().getProductById(id);
    setState(() {
      product = fetchedProduct;
      isLoading = false;
    });
    if (product != null) _loadSellerProfile();
  }

  void _loadSellerProfile() async {
    try {
      final sellerProfile = await _productService.getSellerprofile(
        product!.sellerId,
      );
      if (!mounted || sellerProfile == null) return;
      setState(() {
        sellerId = sellerProfile['id'] ?? '';
        sellerName = sellerProfile['full_name'] ?? '';
        sellerNumber = sellerProfile['phone_number'] ?? '';
        isVerified = sellerProfile['isVerified'] as bool;
      });
    } catch (e) {
      print('Error loading seller profile: $e');
    }
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
              onPressed: () {
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
        user!.id,
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
          // availability badge
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
          // existing cart icon button
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

          //report menu
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
            itemBuilder: (context) => [
              const PopupMenuItem(
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
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ image gallery
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

                    // Price + Category chip row
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

                    // Seller info card
                    SellerCard(
                      isDarkMode: isDarkMode,
                      isVerified: isVerified,
                      sellerName: sellerName ?? 'loading...',
                      sellerNumber: sellerNumber ?? 'loading...',
                    ),
                    const SizedBox(height: 16),

                    // Quick actions (Share + Save)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              // TODO: implement share deep link using product!.id
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share this product',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

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

              // existing floating Contact button (unchanged)
              ContactButton(
                isAvailable: isAvailable,
                isContacting: isContacting,
                contactSeller: contactSeller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
