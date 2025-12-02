import 'package:flutter/material.dart';

class Feedpage extends StatefulWidget {
  const Feedpage({super.key});

  @override
  State<Feedpage> createState() => _FeedpageState();
}

class _FeedpageState extends State<Feedpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('coming later')),
    );
  }
}
