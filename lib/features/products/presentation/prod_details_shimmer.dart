import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProdDetailsShimmer extends StatelessWidget {
  final bool isDark;
  const ProdDetailsShimmer({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? Colors.grey[1000]! : Colors.grey[600]!;
    final highlightColor = isDark ? Colors.grey[1000]! : Colors.grey[800]!;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel Placeholder
              Container(
                height: 320,
                width: double.infinity,
                //margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[100]),
              ),

              const SizedBox(height: 60),

              // Title Placeholder
              Container(
                height: 24,
                width: 200,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              const SizedBox(height: 16),

              // Price Row Placeholder
              Container(
                height: 20,
                width: 120,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              const SizedBox(height: 32),

              // Seller Card Placeholder
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const SizedBox(height: 16),

              // Stock Placeholder
              Container(
                height: 20,
                width: 100,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const SizedBox(height: 16),

              // Description Placeholder
              Container(
                height: 18,
                width: 100,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const SizedBox(height: 8),

              // More From Seller Placeholder
              // Container(
              //   height: 100,
              //   width: double.infinity,
              //   color: Colors.white,
              //   margin: const EdgeInsets.symmetric(horizontal: 16),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
