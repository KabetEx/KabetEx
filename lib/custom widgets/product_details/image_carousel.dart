import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:kabetex/models/product.dart';

class ProductGallery extends StatefulWidget {
  final List<String> images;
  final Product product;
  const ProductGallery({
    super.key,
    required this.images,
    required this.product,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => FullScreenImage(image: images[index]),
                //   ),
                // ); fullscreen Image
                // later...
              },
              child: Hero(
                tag: ValueKey(widget.product.id),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(widget.images[index]),
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
              ),
            );
          },
          options: CarouselOptions(
            height: 320, // Increased height
            enlargeCenterPage: true,
            autoPlay: false,
            enableInfiniteScroll: true,
            viewportFraction: 0.95, // makes images wider
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
                color: isActive ? Colors.black : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }
}
