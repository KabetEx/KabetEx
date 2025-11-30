import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/presentation/full_screen_image.dart';
import 'package:kabetex/providers/theme_provider.dart';

class ProductGallery extends ConsumerStatefulWidget {
  final List<String> images;
  final Product product;
  const ProductGallery({
    super.key,
    required this.images,
    required this.product,
  });

  @override
  ConsumerState<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends ConsumerState<ProductGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: widget.images.length,
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImagePage(
                        images: widget.images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.images[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 320, // Increased height
              enlargeCenterPage: true,
              autoPlay: false,
              initialPage: 0,
              enableInfiniteScroll: false,
              viewportFraction: 1, // makes images wider
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),

          const SizedBox(height: 16),

          //child 2 => dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              final bool isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 8, // wider active dot
                height: 8,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? isActive
                            ? Colors.deepOrange
                            : Colors.white
                      : isActive
                      ? Colors.deepOrange
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
