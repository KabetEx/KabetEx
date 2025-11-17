import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/home/product_card.dart';
import 'package:kabetex/pages/auth/sign_up.dart';
import 'package:kabetex/providers/seller_products/my_products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProductsPage extends ConsumerWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProductsAsync = ref.watch(myProductsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
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
      appBar: AppBar(title: const Text("My Products")),
      body: myProductsAsync.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}
