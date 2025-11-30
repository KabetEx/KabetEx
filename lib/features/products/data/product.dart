class Product {
  final String? id;
  final String title;
  final String category;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerNumber;
  final bool? isActive;
  final int views;
  final int quantity;

  Product({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerNumber,
    required this.quantity,
    this.views = 0,
    this.isActive,
  });

  // inserting/updating to Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'image_urls': imageUrls,
      'seller_number': sellerNumber,
      'seller_id': sellerId,
      'views': views,
      'quantity': quantity,
    };
  }

  // from Supabase
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(), // supabase numeric → double
      imageUrls: List<String>.from(
        map['image_urls'] ?? [],
      ), //explicitly convert 'image_urls' to List<String>
      sellerId: map['seller_id'] as String,
      sellerNumber: map['seller_number'] as String,
      isActive: map['isActive'] as bool,
      views: (map['views'] as num).toInt(),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  // Helper to increment views
  Product incrementViews() {
    return Product(
      id: id,
      title: title,
      category: category,
      description: description,
      price: price,
      imageUrls: imageUrls,
      sellerId: sellerId,
      sellerNumber: sellerNumber,
      isActive: isActive,
      quantity: quantity,
      views: views + 1,
    );
  }
}
