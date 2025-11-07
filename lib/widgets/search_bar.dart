import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key, required this.hint});

  final String hint;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: TextField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: const OutlineInputBorder(),
            hintText: hint,
            suffixIcon: const Icon(Icons.search),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }
}
