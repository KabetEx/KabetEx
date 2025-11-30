import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//used for current logged in user
final futureProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return AuthService().getProfile();
});

//check if user exists
final authUserProvider = StreamProvider((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (data) => data.session?.user,
  );
});

//my products provider
final myProductsProvider = FutureProvider<List<Product>?>((ref) async {
  final userAsync = ref.watch(authUserProvider);

  // Wait until the user is loaded
  final user = userAsync.maybeWhen(data: (u) => u, orElse: () => null);

  if (user == null) return []; // no user yet

  return ProductService().getMyProducts(user.id);
});
