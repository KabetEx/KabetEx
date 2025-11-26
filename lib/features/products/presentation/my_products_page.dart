import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/features/products/presentation/edit_product.dart';
import 'package:kabetex/features/products/widgets/SellerProductTile.dart';
import 'package:kabetex/providers/products/seller_products/my_products.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MyProductsPage extends ConsumerWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProductsAsync = ref.watch(myProductsProvider);
    final authSync = ref.watch(authUserProvider);

    final isDark = ref.watch(isDarkModeProvider);
    final supabase = ProductService();

    void delete(Product p) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: isDark
                ? Colors.grey
                : const Color.fromARGB(255, 171, 171, 171),
            title: Text(
              'Are you sure you want to delete your product?',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await supabase.deleteProduct(p.id!, p.imageUrls);
                      ref.refresh(
                        myProductsProvider,
                      ); // Refresh the product list

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item deleted successfuly'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("$e")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          );
        },
      );
    }

    void edit(Product product) {
      Navigator.push(
        context,
        SlideRouting(page: EditProductPage(product: product)),
      );
    }

    //   return Scaffold(
    //     backgroundColor: isDark
    //         ? Colors.black
    //         : const Color.fromARGB(255, 237, 228, 225),
    //     appBar: AppBar(
    //       title: const Text('Upload a product'),
    //       centerTitle: true,
    //     ),
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           const Text('You have to create \n an account to post'),
    //           ElevatedButton(
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.deepOrange,
    //             ),
    //             onPressed: () {
    //               Navigator.pushReplacement(
    //                 context,
    //                 MaterialPageRoute(builder: (context) => const SignupPage()),
    //               );
    //             },
    //             child: const Text('Create an account'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Products",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: authSync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("You need an account"));
          }
          return myProductsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e")),
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Text(
                    "You haven't posted anything yet 👀",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }

              //else
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (_, index) {
                  final product = products[index];
                  return SellerProductTile(
                    product: product,
                    onDelete: delete,
                    onEdit: edit,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
