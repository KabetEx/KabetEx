import 'package:flutter/material.dart';

enum Categories { all, food, electronics, clothing, books }

class MyCategoryGrid extends StatefulWidget {
  const MyCategoryGrid({super.key});

  @override
  State<MyCategoryGrid> createState() => _MyCategoryGridState();
}

class _MyCategoryGridState extends State<MyCategoryGrid> {
  String _selectedCat = 'all';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
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
                  horizontal: 8,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedCat == cat.name
                        ? Colors.black
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        blurRadius: 3,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: Text(
                    cat.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: _selectedCat == cat.name
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
