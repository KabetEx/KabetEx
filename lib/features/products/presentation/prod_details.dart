import 'package:flutter/material.dart';
import 'package:kabetex/core/snackbars.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/features/products/providers/prod_details_provider.dart';
import 'package:kabetex/features/products/widgets/prod_details/contact_button.dart';
import 'package:kabetex/features/products/widgets/prod_details/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/widgets/prod_details/more_from_seller.dart';
import 'package:kabetex/features/products/widgets/prod_details/price_row.dart';
import 'package:kabetex/features/products/widgets/prod_details/report_product.dart';
import 'package:kabetex/features/products/widgets/prod_details/seller_card.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    product = widget.product;

    if (product == null && widget.productId != null) {
      print(widget.productId);
      fetchProduct(widget.productId!);
    }
  }

  //navigation by cart
  Future<void> fetchProduct(String id) async {
    //final isDark = ref.watch(isDarkModeProvider);

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final fetchedProduct = await ProductService().getProductById(id);

      if (!mounted) return;

      setState(() {
        product = fetchedProduct;
      });
      print(product);
    } catch (e) {
      FailureSnackBar.show(
        context,
        'Failed to load product $e',
        ref.watch(isDarkModeProvider),
      );
      print('$e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      } else {
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

    // 1. Get access to the controller itself (the functions)
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
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
                    RepaintBoundary(
                      child: ProductGallery(
                        images: product!.imageUrls,
                        product: product!,
                      ),
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
                    RepaintBoundary(
                      child: PriceRow(product: product!, isDark: isDarkMode),
                    ),

                    const SizedBox(height: 16),

                    RepaintBoundary(
                      child: SellerCard(
                        isDark: isDarkMode,
                        sellerId: product!.sellerId,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: sectionHeadingColor,
                                  ),
                            ),
                            TextSpan(
                              text: product!.quantity.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    //description
                    ProdDescription(
                      productDescription: product!.description,
                      isDark: isDarkMode,
                    ),
                    const SizedBox(height: 16),

                    // MORE FROM SELLER section header
                    RepaintBoundary(
                      child: MoreFromSeller(
                        product: product!,
                        isDark: isDarkMode,
                      ),
                    ),
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
    final isDark = ref.watch(isDarkModeProvider);

    return IconButton(
      onPressed: () {
        if (isExisting) {
          ref.read(cartProvider.notifier).remove(product.id!);
          SuccessSnackBar.show(
            context: context,
            message: 'Item removed from cart',
            isDark: isDark,
            duration: 1,
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
          SuccessSnackBar.show(
            context: context,
            message: 'Item added to cart',
            isDark: isDark,
            duration: 1,
          );
        }
      },
      icon: AnimatedScale(
        scale: isExisting ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Icon(
          isExisting
              ? Icons.check_circle_outline_sharp
              : Icons.shopping_cart_outlined,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1,
            child: Text(
              productDescription,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.45,
                color: isDark ? Colors.white.withAlpha(200) : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
