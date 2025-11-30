import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/providers/all_products_provider.dart';
import 'package:kabetex/features/products/providers/seller_provider.dart';
import 'package:kabetex/providers/cart/all_cart_products.dart';
import 'package:riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsController extends StateNotifier<AsyncValue<Product>> {
  ProductDetailsController(this.ref, Product product)
    : super(AsyncValue.data(product));

  final Ref ref;
  final _service = ProductService();

  // ---------------------------------------------------------------------------
  // FETCH PRODUCT (FOR NAVIGATION BY ID)
  // ---------------------------------------------------------------------------
  Future<void> fetchProduct(String id) async {
    try {
      final product = await _service.getProductById(id);
      if (product == null) {
        state = AsyncValue.error('Product not found', StackTrace.current);
        return;
      }

      state = AsyncValue.data(product);

      // increment views after data loads
      ref.read(productViewProvider(product).notifier).increment();
    } catch (e, st) {
      log("Fetch product error: $e");
      state = AsyncValue.error(e, st);
    }
  }

  // ---------------------------------------------------------------------------
  // CART HANDLING
  // ---------------------------------------------------------------------------
  bool isInCart(Product product) {
    final cart = ref.watch(cartProvider);
    return cart.any((p) => p.id == product.id);
  }

  void toggleCart(Product product, BuildContext context) {
    final isExist = isInCart(product);

    if (isExist) {
      ref.read(cartProvider.notifier).remove(product.id!);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added to cart')));
    }
  }

  // ---------------------------------------------------------------------------
  // REPORT PRODUCT
  // ---------------------------------------------------------------------------

  void showReportDialog(BuildContext context, Product product) {
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
                  : () async {
                     await reportProduct(selectedReason!, context);
                    },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  //
  Future<void> reportProduct(String reason, BuildContext context) async {
    try {
      await ProductService().reportProduct(
        state.value!.id!,
        state.value!.sellerId,
        reason,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reported: $reason')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to report: $e')));
    } finally {
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------------------
  // WHATSAPP CONTACT
  // ---------------------------------------------------------------------------
  String _cleanNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('0')) input = input.substring(1);
    if (input.startsWith('254')) return input;
    return '254$input';
  }

  Future<void> contactSeller() async {
    final product = state.value;

    ref.read(isContactingProvider.notifier).state = true;

    try {
      final seller = await ref.read(
        sellerProfileProvider(product!.sellerId).future,
      );

      print(seller);

      final number = seller?['phone_number'];
      print('seller profile $number');

      if (number == null) {
        print('Number is null');
        return;
      }

      final cleaned = _cleanNumber(number);
      print('Number cleaned $cleaned'.toString());

      await _openWhatsApp(
        cleaned,
        "Hey! I found your product '${product.title}' on KabetEx and I'm interested.",
      );
    } catch (e) {
      print("Contact error: $e");
    } finally {
      ref.read(isContactingProvider.notifier).state = false;
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String msg) async {
    final encoded = Uri.encodeComponent(msg);
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
  }
}

final isContactingProvider = StateProvider<bool>((ref) => false);
