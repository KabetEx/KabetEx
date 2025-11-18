import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/pages/auth/sign_up.dart';
import 'package:kabetex/pages/sellers-section-pages/my_products/SellerProductTile.dart';
import 'package:kabetex/providers/seller_products/my_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProductsPage extends ConsumerWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProductsAsync = ref.watch(myProductsProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark
            ? Colors.black
            : const Color.fromARGB(255, 237, 228, 225),
        appBar: AppBar(
          title: const Text('Upload a product'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('You have to create \n an account to post'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      appBar: AppBar(title: const Text("My Products")),
      body: myProductsAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        error: (e, st) => Center(child: Text("Error: $e")),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text("You haven't posted anything yet 👀"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              return SellerProductTile(product: product);
            },
          );
        },
      ),
    );
  }
}
