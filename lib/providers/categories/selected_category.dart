import 'package:riverpod/legacy.dart';
import 'package:kabetex/features/categories/data/dummy_categories.dart';

final selectedCategoryProvider = StateProvider<String>((ref) {
  return categories[0]['name']; //defaults to category 'all'
});
