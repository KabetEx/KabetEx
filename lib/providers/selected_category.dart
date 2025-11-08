import 'package:flutter/foundation.dart';
import 'package:kabetex/models/product.dart';
import 'package:riverpod/legacy.dart';

final selectedCategoryProvider = StateProvider<Categories>((ref) {
  return Categories.all;
});
