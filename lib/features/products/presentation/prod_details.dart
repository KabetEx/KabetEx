import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/presentation/prod_details_shimmer.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/features/products/providers/prod_details_provider.dart';
import 'package:kabetex/features/products/widgets/prod_details/contact_button.dart';
import 'package:kabetex/features/products/widgets/prod_details/image_carousel.dart';
import 'package:kabetex/features/products/widgets/prod_details/more_from_seller.dart';
import 'package:kabetex/features/products/widgets/prod_details/price_row.dart';
import 'package:kabetex/features/products/widgets/prod_details/report_product.dart';
import 'package:kabetex/features/products/widgets/prod_details/seller_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool isLoaded = false;

  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    product = widget.product;

    if (product == null && widget.productId != null) {
      _fetchProduct(widget.productId!);
    } else {
      // product was passed, show immediately
      isLoaded = true;
    }
  }

  //FETCH BY ID IF NAVIGATED BY CART
  Future<void> _fetchProduct(String id) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final fetchedProduct = await ref
          .read(productsProvider.notifier)
          .getProductById(id);
      if (!mounted) return;

      setState(() => product = fetchedProduct);

      if (mounted) setState(() => isLoaded = true);
    } catch (e) {
      FailureSnackBar.show(
        context: context,
        message: 'Failed to load product $e',
        isDark: ref.watch(isDarkModeProvider),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final sectionHeadingColor = isDarkMode ? Colors.white : Colors.black87;

    if (isLoading && product == null) {
      return const ProdDetailsShimmer();
    }

    if (product == null) return const Center(child: Text('Product not found'));

    final isAvailable = product!.isActive ?? true;

    // Trigger view increment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productViewProvider(product!).notifier).increment();
    });

    final controller = ref.read(
      productDetailsControllerProvider(product!).notifier,
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLoaded ? 1.0 : 0.0,
      curve: isLoaded ? Curves.easeIn : Curves.linear,
      child: Scaffold(
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
            AddToCart(product: product!),
            ReportProduct(isDark: isDarkMode, product: product!),
          ],
        ),
        body: Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: isLoaded ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: SafeArea(
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //PRODUCT IMAGES
                        RepaintBoundary(
                          child: ProductGallery(
                            images: product!.imageUrls,
                            product: product!,
                          ),
                        ),
                        const SizedBox(height: 16),

                        //PRODUCT TITLE
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

                        //PRODUCT PRICE
                        RepaintBoundary(
                          child: PriceRow(
                            product: product!,
                            isDark: isDarkMode,
                          ),
                        ),
                        const SizedBox(height: 16),

                        //SELLER CARD
                        RepaintBoundary(
                          child: SellerCard(
                            isDark: isDarkMode,
                            sellerId: product!.sellerId,
                          ),
                        ),
                        const SizedBox(height: 16),

                        //STOCK
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

                        //PRODUCT DESCRIPTION
                        ProdDescription(
                          productDescription: product!.description,
                          isDark: isDarkMode,
                        ),
                        const SizedBox(height: 16),

                        //MORE FROM SELLER
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
            ),
            ContactButton(
              isAvailable: isAvailable,
              onpressed: controller.contactSeller,
            ),
          ],
        ),
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
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.cart_badge_plus,
          size: 28,
          color: Colors.deepOrange,
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
