import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';

class AppTitleRow extends ConsumerStatefulWidget {
  const AppTitleRow({super.key});

  @override
  ConsumerState<AppTitleRow> createState() => _AppTitleRowState();
}

class _AppTitleRowState extends ConsumerState<AppTitleRow> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
      child: Column(
        children: [
          //first row
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              right: 8,
              left: 8,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //menu icon
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Icon(
                    Icons.menu_rounded,
                    size: 32,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),

                const Spacer(),

                //theme switch
                Switch(
                  value: isDarkMode,
                  onChanged: (newval) {
                    ref.read(isDarkModeProvider.notifier).state = newval;
                  },
                ),
              ],
            ),
          ),
          //2nd row
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello Moha',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                      height: 1,
                    ),
                  ),
                  Text(
                    'Lets shop!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
