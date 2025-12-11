//used in product details page
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/models/user.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//sellers profile
final sellerProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  sellerId,
) async {
  try {
    final supabase = Supabase.instance.client;

    final res = await supabase
        .from('profiles')
        .select('id, full_name, phone_number, avatar_url, isVerified')
        .eq('id', sellerId)
        .maybeSingle();

    print('seller profile: $sellerId');

    return UserProfile.fromMap(res); // returns null if not found
  } catch (e) {
    print('Error fetching profile $e');
    throw Exception('Failed to fetch seller profile');
  }
});

final sellerProductsProvider = FutureProvider.family<List<Product>?, String>((
  ref,
  sellerId,
) async {
  final productService = ProductService();

  try {
    final sellerProducts = await productService.getMyProducts(sellerId);
    return sellerProducts;
  } catch (e) {
    print('error: $e');
    return null;
  }
});
