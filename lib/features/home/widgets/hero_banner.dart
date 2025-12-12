import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MyHeroBanner extends StatelessWidget {
  const MyHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 120,
          autoPlay: false,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true, //  show part of next slide
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
