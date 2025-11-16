import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // ---------------- UPLOAD IMAGES ----------------
  Future<List<String>> uploadImages(List<Uint8List> images) async {
    List<String> urls = [];

    for (var i = 0; i < images.length; i++) {
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final response = await supabase.storage
          .from('product-images')
          .uploadBinary(fileName, images[i]);

      final publicUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(fileName);
      urls.add(publicUrl);
    }

    return urls;
  }

  // ---------------- CREATE PRODUCT ----------------
  Future<void> createProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    required List<String> imageUrls,
    required String sellerId,
  }) async {
    await supabase.from('products').insert({
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'image_urls': imageUrls, // your text[] column
      'seller_id': sellerId,
    });
  }

  // fetch products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await supabase.from('products').select().eq('isActive', true);
    return List<Map<String, dynamic>>.from(res);
  }

  //convert getProducts() to a stream
  Stream<List<Map<String, dynamic>>> productsStream() async* {
    while (true) {
      final products = await ProductService().getProducts();
      yield products;
      await Future.delayed(const Duration(seconds: 5)); // auto-refresh every 5s
    }
  }
}
