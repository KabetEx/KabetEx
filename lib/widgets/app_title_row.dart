import 'package:flutter/material.dart';

class AppTitleRow extends StatelessWidget {
  const AppTitleRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 8, left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //menu icon
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: const Icon(Icons.menu_rounded, size: 32),
          ),
          Text('K a b e t E x', style: Theme.of(context).textTheme.titleLarge),
          //cart icon with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_rounded, size: 32),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  alignment: Alignment.center,
                  height: 18,
                  width: 18,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
