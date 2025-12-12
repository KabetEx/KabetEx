import 'package:flutter/material.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/widgets/products_listview.dart';
import 'package:kabetex/features/products/widgets/products_shimmer.dart';

class HomeProductsSection extends StatefulWidget {
  const HomeProductsSection({
    super.key,
    required this.isLoading,
    required this.isLoadingMore,
    required this.products,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final List<Product> products;

  @override
  State<HomeProductsSection> createState() => _HomeProductsSectionState();
}

class _HomeProductsSectionState extends State<HomeProductsSection>
    with SingleTickerProviderStateMixin {
  late Animation<double> _fade;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    //initializing the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    //defining the fade animation
    _fade = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    //start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Products or shimmer
        if (widget.isLoading || widget.products.isEmpty)
          const ProductsShimmer()
        else
          FadeTransition(
            opacity: _fade,
            child: MyProductsGridview(products: widget.products),
          ),

        // Loading more indicator
        if (widget.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
