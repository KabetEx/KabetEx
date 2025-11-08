class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  final String id;
  final String name;
  final Categories category;
  final double price;
  final String imageUrl;
  final String description;
}

enum Categories { all, food, electronics, clothing, books }
