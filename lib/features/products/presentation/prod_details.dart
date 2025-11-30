import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/features/products/providers/prod_details_provider.dart';
import 'package:kabetex/features/products/providers/seller_provider.dart';
import 'package:kabetex/features/products/widgets/contact_button.dart';
import 'package:kabetex/features/products/widgets/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/widgets/more_from_seller.dart';
import 'package:kabetex/features/products/widgets/price_row.dart';
import 'package:kabetex/features/products/widgets/product_card.dart';
import 'package:kabetex/features/products/widgets/report_product.dart';
import 'package:kabetex/features/products/widgets/seller_card.dart';
import 'package:kabetex/features/products/widgets/shimmer_grid.dart';
import 'package:kabetex/features/products/widgets/trending_badge.dart';
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
  }

  //navigation by cart
  Future<void> fetchProduct(String id) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final fetchedProduct = await ProductService().getProductById(id);

      if (!mounted) return;

      setState(() {
        product = fetchedProduct;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load product')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final sectionHeadingColor = isDarkMode ? Colors.white : Colors.black87;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (product == null) return const Center(child: Text('Product not found'));

    final isAvailable = product!.isActive ?? true;

    // Trigger increment once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productViewProvider(product!).notifier).increment();
    });

    // 1. Get the controller state

    // 2. Get access to the controller itself (the functions)
    final controller = ref.read(
      productDetailsControllerProvider(product!).notifier,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
          //add to cart
          AddToCart(product: product!),
          ReportProduct(isDark: isDarkMode, product: product!),
          //popmenuButton
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
                    //title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        product!.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    //price category row
                    PriceRow(product: product!, isDark: isDarkMode),

                    const SizedBox(height: 16),

                    SellerCard(isDark: isDarkMode, sellerId: product!.sellerId),
                    const SizedBox(height: 8),

                    //stock
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Stock: ',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    fontFamily: 'Roboto Slab',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: sectionHeadingColor,
                                  ),
                            ),
                            TextSpan(
                              text: product!.quantity.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //description
                    const SizedBox(height: 16),
                    ProdDescription(
                      productDescription: product!.description,
                      isDark: isDarkMode,
                    ),

                    // MORE FROM SELLER section header
                    MoreFromSeller(product: product!, isDark: isDarkMode),
                  ],
                ),
              ),
            ),
          ),
          ContactButton(
            isAvailable: isAvailable,
            onpressed: controller.contactSeller,
          ),
        ],
      ),
    );
  }
}

class AddToCart extends ConsumerWidget {
  const AddToCart({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, ref) {
    final cart = ref.watch(cartProvider);
    final isExisting = cart.any((p) => p.id == product.id);

    return IconButton(
      onPressed: () {
        if (isExisting) {
          ref.read(cartProvider.notifier).remove(product.id!);
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
                  id: product.id!,
                  title: product.title,
                  price: product.price,
                  imageUrl: product.imageUrls[0],
                  category: product.category,
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
        scale: isExisting ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Icon(
          isExisting ? Icons.check_circle_sharp : Icons.shopping_cart_outlined,
          color: Colors.green,
        ),
      ),
    );
  }
}

class ProdDescription extends StatelessWidget {
  const ProdDescription({
    super.key,
    required this.productDescription,
    required this.isDark,
  });

  final String productDescription;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final descColor = isDark ? Colors.white70 : Colors.grey[800];
    final sectionHeadingColor = isDark ? Colors.white : Colors.black87;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Description',
            style: TextStyle(
              fontFamily: 'Roboto Slab',
              fontSize: 18,
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
            productDescription,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: descColor,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
