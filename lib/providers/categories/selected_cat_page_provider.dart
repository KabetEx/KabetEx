import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';

final selectedCategoryProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, category) async {
      return await ProductService().getSelectedCategoryProducts(category);
    });
