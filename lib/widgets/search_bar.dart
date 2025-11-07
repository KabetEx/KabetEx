import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key, required this.hint});

  final String hint;

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  bool get isLightMode {
    return Theme.of(context).brightness == Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: TextField(
          decoration: InputDecoration(
            //not focused border
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isLightMode ? Colors.black : Colors.white,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            //focused border
            focusedBorder: const OutlineInputBorder(),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: isLightMode ? Colors.black54 : Colors.white70,
            ),
            suffixIcon: Icon(
              Icons.search,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }
}
