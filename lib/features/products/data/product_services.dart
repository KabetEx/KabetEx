import 'dart:typed_data';
import 'package:kabetex/features/products/data/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;

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

  //get seller's profile
  Future<Map<String, dynamic>?> getSellerprofile(String sellerId) async {
    try {
      final res = await supabase
          .from('profiles')
          .select('id, full_name, phone_number, isVerified')
          .eq('id', sellerId)
          .maybeSingle();

      print('fetching profile for seller: $sellerId');

      if (res == null) {
        return null;
      }
      return res;
    } catch (e) {
      print('Error fetching profile $e');
    }
    return null;
  }

  Future<void> reportProduct(
    String productId,
    String sellerId,
    String selectedReason,
  ) async {
    if (user == null) return;
    try {
      await supabase.from('reports').insert({
        'product_id': productId,
        'seller_id': sellerId,
        'reason': selectedReason,
        'reporter_id': supabase.auth.currentUser!.id,
      });
    } catch (e) {
      print('Error reporting: $e');
      rethrow;
    }
  }

  //  get seller Whatsapp number
  Future<String?> getSellerNumber(String sellerId) async {
    final res = await supabase
        .from('products')
        .select('seller_number')
        .eq('seller_id', sellerId) //if 'seller_id' matchs the seller's id
        .maybeSingle(); //max 1 row (product)
    if (res == null) return null;
    return res['seller_number'];
  }

  //  create product
  Future<void> createProduct(Product product) async {
    await supabase.from('products').insert(product.toMap());
  }

  //-----------------fetch my products----------------------------//
  Future<List<Product>?> getMyProducts(String sellerId) async {
    final res = await supabase
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (res as List<dynamic>?)?.map((p) {
          return Product.fromMap(p);
        }).toList() ??
        [];
  }

  //delete product
  Future<void> deleteProduct(String productId, List<String> imageUrls) async {
    final imagePath = imageUrls.map((url) {
      return url.split('/product-images/').last;
    }).toList();

    try {
      //delete products record first
      final res = await supabase
          .from('products')
          .delete()
          .eq('id', productId) //which product to delete
          .eq('seller_id', user!.id); //whose product to delete

      //delete images
      if (imagePath.isNotEmpty) {
        await supabase.storage.from('product-images').remove(imagePath);
      }
    } catch (e) {
      rethrow;
    }
  }

  //edit product
  Future<void> updateProduct(
    String id,
    String title,
    String description,
    String price,
    String category,
  ) async {
    try {
      if (user == null) throw Exception('User not logged in');

      await supabase
          .from('products')
          .update({
            'title': title,
            'description': description,
            'price': price,
            'category': category,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('seller_id', user!.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('id', id)
          .single(); // ensures we get just one

      // convert map to Product object
      return Product.fromMap(response);
    } catch (e) {
      print('Exception fetching product: $e');
      return null;
    }
  }

  //---------- fetch active products, newer first---//
  Stream<List<Product>> getProductsStream() {
    supabase
        .from('products')
        .select()
        .eq('isActive', true)
        .order('created_at', ascending: false);

    final allProducts = supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('isActive', true)
        .order('created_at', ascending: false)
        .map((maps) {
          return maps.map((map) {
            return Product.fromMap(map);
          }).toList();
        });
    return allProducts;
  }

  // Fetch active products, newest first, with pagination
  Future<List<Product>> fetchProducts({int limit = 20, int offset = 0}) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('isActive', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final products = (response as List)
        .map((map) => Product.fromMap(map))
        .toList();

    return products;
  }

  //get specific category products
  Future<List<Product>> getSelectedCategoryProducts(String category) async {
    final res = await (category != 'all'
        ? supabase
              .from('products')
              .select()
              .eq('category', category)
              .order('created_at', ascending: false) // select selected category
        : supabase
              .from('products')
              .select()
              .order('created_at', ascending: false)); //select all products

    final selectedcatProducts = (res).map((map) {
      return Product.fromMap(map);
    }).toList();

    return selectedcatProducts;
  }

  // Increment views in Supabase
  Future<int> incrementViews(String productId, int currentViews) async {
    final newViews = currentViews + 1;
    try {
      await supabase
          .from('products')
          .update({'views': newViews})
          .eq('id', productId);
      print('Incrementing views for ID: $productId');
    } catch (e) {
      print('Error incrementing views');
    }
    return newViews; // return updated count
  }
}
