import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final myProductsProvider = FutureProvider((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  return ProductService().getMyProducts(user.id);
});
