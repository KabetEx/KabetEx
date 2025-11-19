import 'dart:typed_data';
import 'package:kabetex/features/products/data/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // ---------------- UPLOAD IMAGES ----------------//
  Future<List<String>> uploadImages(List<Uint8List> images) async {
    List<String> urls = []; //empty list

    //loop through each image and return its string url
    for (var i = 0; i < images.length; i++) {
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg'; //create filename(path)
      await supabase.storage
          .from('product-images')
          .uploadBinary(fileName, images[i]);

      //get image's url
      final publicUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(fileName);
      urls.add(publicUrl); //add it to the list
    }

    return urls;
  }

  //get seller Whatsapp number
  Future<String?> getSellerNumber(String sellerId) async {
    final res = await supabase
        .from('products')
        .select('seller_number')
        .eq('seller_id', sellerId) //if 'seller_id' matchs the seller's id
        .maybeSingle(); //max 1 row (product)
    if (res == null) return null;
    return res['seller_number'];
  }

  // ---------------- CREATE PRODUCT ----------------
  Future<void> createProduct(Product product) async {
    await supabase.from('products').insert(product.toMap());
  }

  //fetch specific user's products
  Future<List<Product>> getMyProducts(String sellerId) async {
    final res = await supabase
        .from('products')
        .select()
        .eq('seller_id', sellerId);

    return (res as List<dynamic>?)?.map((p) {
          return Product.fromMap(p);
        }).toList() ??
        [];
  }

  // fetch active products, newer first
  Stream<List<Product>> getProductsStream() {
    supabase
        .from('products')
        .select()
        .eq('isActive', true)
        .order('created_at', ascending: false);

    //listen to changes from products tables
   final allProducts  = supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('isActive', true).order('created_at', ascending: false)
        .map((maps) {
          return maps.map((map) {
            return Product.fromMap(map);
          }).toList();
        });
        return allProducts;
  }
}
