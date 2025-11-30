import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/search/providers/search_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class MySearchBar extends ConsumerStatefulWidget {
  const MySearchBar({super.key, required this.hint});

  final String hint;

  @override
  ConsumerState<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends ConsumerState<MySearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<Color?> _borderAnimation;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _borderAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.deepOrange,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Start animation when typing
    _animationController.forward(from: 0);

    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Update Riverpod state after debounce
      ref.read(searchQueryProvider.notifier).state = value;
    });

    // Update the controller cursor position
    searchController.value = searchController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final query = ref.watch(searchQueryProvider);

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return TextField(
              autocorrect: true,
              autofocus: true,
              enableSuggestions: true,
              controller: searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.white
                        : _borderAnimation.value ?? Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _borderAnimation.value ?? Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
              ),
              keyboardType: TextInputType.text,
              onChanged: _onSearchChanged,
            );
          },
        ),
      ),
    );
  }
}
