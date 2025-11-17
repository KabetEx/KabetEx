import 'package:kabetex/services/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Product {
  final String? id;
  final String title;
  final String category;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerNumber;

  Product({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerNumber,
  });

  // Convert Product to a map for inserting/updating in Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'image_urls': imageUrls,
      'seller_number': sellerNumber,
      'seller_id': sellerId,
    };
  }

  // Factory constructor to create a Product from Supabase map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(), // supabase numeric → double
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      sellerId: map['seller_id'] as String,
      sellerNumber: map['seller_number'] as String,
    );
  }
}
