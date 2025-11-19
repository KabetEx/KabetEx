import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/categories/data/dummy_categories.dart';

final allCategoriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return categories;
});
