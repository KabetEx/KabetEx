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
  final String category;
  final double price;
  final List<String> imageUrl;
  final String description;
}
