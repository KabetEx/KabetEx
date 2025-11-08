import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MySearchBar extends ConsumerStatefulWidget {
  const MySearchBar({super.key, required this.hint});

  final String hint;

  @override
  ConsumerState<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends ConsumerState<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: TextField(
          decoration: InputDecoration(
            //not focused border
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white : Colors.black,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            //focused border
            focusedBorder: const OutlineInputBorder(),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            suffixIcon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }
}
