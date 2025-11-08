import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';

enum Categories { all, food, electronics, clothing, books }

class MyCategoryGrid extends ConsumerStatefulWidget {
  const MyCategoryGrid({super.key});

  @override
  ConsumerState<MyCategoryGrid> createState() => _MyCategoryGridState();
}

class _MyCategoryGridState extends ConsumerState<MyCategoryGrid> {
  String _selectedCat = 'all';

  @override
  Widget build(BuildContext context) {
    final isLightMode = ref.watch(isDarkModeProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 12,
          top: 0,
          bottom: 0,
        ),
        child: Row(
          children: Categories.values.map((cat) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCat = cat.name;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        //if selected
                        _selectedCat == cat.name
                        ? isLightMode
                              ? const Color.fromARGB(255, 237, 237, 237)
                              : Colors.black
                        :
                          //if is not selected
                          isLightMode
                        ? Colors.black
                        : Colors.white,

                    boxShadow: [
                      BoxShadow(
                        color: isLightMode ? Colors.grey : Colors.black,
                        blurRadius: 3,
                        offset: const Offset(1, 0.5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: Text(
                    cat.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color:
                          //if selected
                          _selectedCat == cat.name
                          ? isLightMode
                                ? Colors.black
                                : Colors.white
                          //not selected
                          : isLightMode
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
