import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/providers/product_details_controller.dart';
import 'package:riverpod/legacy.dart';

final productDetailsControllerProvider =
    StateNotifierProvider.family<
      ProductDetailsController,
      AsyncValue<Product>,
      Product
    >((ref, product) => ProductDetailsController(ref, product));
