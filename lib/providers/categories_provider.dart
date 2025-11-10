import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/dummy%20data/dummy_categories.dart';

final allCategoriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return categories;
});
