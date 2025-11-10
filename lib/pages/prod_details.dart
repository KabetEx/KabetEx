import 'package:flutter/material.dart';
import 'package:kabetex/custom widgets/gradient_container.dart';
import 'package:kabetex/custom widgets/product_details/image_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';

class ProdDetailsPage extends ConsumerStatefulWidget {
  const ProdDetailsPage({super.key, required this.product});

  final Product product;
  @override
  ConsumerState<ProdDetailsPage> createState() => _ProdDetailsPageState();
}

class _ProdDetailsPageState extends ConsumerState<ProdDetailsPage> {
  @override
  Widget build(BuildContext context) {
    //final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: MyGradientContainer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ProductGallery(
                  images: widget.product.imageUrl,
                  product: widget.product,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
