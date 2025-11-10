import 'package:flutter/material.dart';
import 'package:kabetex/custom%20widgets/gradient_container.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart ')),
      body: const MyGradientContainer(child: Text('')),
    );
  }
}
