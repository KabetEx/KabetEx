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
          const Icon(Icons.menu_rounded),
          Text('KABETEX', style: Theme.of(context).textTheme.titleLarge),
          const Icon(Icons.trolley),
        ],
      ),
    );
  }
}
