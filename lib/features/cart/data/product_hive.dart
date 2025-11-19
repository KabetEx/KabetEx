import 'package:hive/hive.dart';

part 'product_hive.g.dart';

@HiveType(typeId: 0)
class ProductHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String imageUrl;

  @HiveField(2)
  String title;

  @HiveField(3)
  double price;

  @HiveField(4)
  String category;

  ProductHive({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}
