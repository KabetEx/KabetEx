import 'dart:typed_data';
import 'package:kabetex/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // ---------------- UPLOAD IMAGES ----------------
  Future<List<String>> uploadImages(List<Uint8List> images) async {
    List<String> urls = [];

    for (var i = 0; i < images.length; i++) {
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      await supabase.storage
          .from('product-images')
          .uploadBinary(fileName, images[i]);

      final publicUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(fileName);
      urls.add(publicUrl);
    }

    return urls;
  }

  //get seller Whatsapp number
  Future<String?> getSellerNumber(String sellerId) async {
    final res = await supabase
        .from('products')
        .select('seller_number')
        .eq('seller_id', sellerId)
        .maybeSingle();
    if (res == null) return null;
    return res['seller_number'];
  }

  // ---------------- CREATE PRODUCT ----------------
  Future<void> createProduct(Product product) async {
    await supabase.from('products').insert(product.toMap());
  }

  //fetch specific user products
  Future<List<Product>> getMyProducts(String sellerId) async {
    final res = await supabase
        .from('products')
        .select()
        .eq('seller_id', sellerId);

    return res.map((p) {
      return Product.fromMap(p);
    }).toList();
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
