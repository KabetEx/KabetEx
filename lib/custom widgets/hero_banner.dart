import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MyHeroBanner extends StatelessWidget {
  const MyHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 1),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 140,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),

          enlargeCenterPage: true,
          viewportFraction: 0.9,
        ),
        items: ['assets/images/hero2.jpeg', 'assets/images/hero1.jpeg'].map((
          imagePath,
        ) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        }).toList(),
      ),
    );
  }
}
